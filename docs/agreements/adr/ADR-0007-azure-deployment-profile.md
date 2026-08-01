# ADR-0007: E1 Azure deployment profile and budget guardrail

- **Status:** proposed
- **Date:** 2026-08-01
- **Supersedes:** ADR-0004 only where it says STT and TTS are Foundry model
  calls; its staged STT -> LLM -> TTS pipeline and swap point remain in force

> Acceptance convention (decision Q3, ADR-0001): this ADR becomes `accepted`
> when a human merges the agreements PR that contains it; the Status line is
> updated to `accepted` at that point, never by an agent beforehand.

## Context

E1 must leave no region, resource, AI backing, identity, configuration-storage,
hosting, or budget choice to later implementation Tasks. The human decisions on
Task [#31](https://github.com/mrmo-sandbox/present-stackchan-for-misaki-hbd-v2/issues/31)
fix the privately selected local-default subscription, `eastus2` for every
regional E1 resource, one production-as-development resource group, minimum
viable SKUs, no high availability, keyless runtime access, the canonical project
slug `present-stackchan-for-misaki-hbd-v2`, and a monthly JPY 2,000 actual-cost
budget with 50%, 80%, and 100% notifications. No subscription, tenant, account,
recipient, credential, or other environment-specific value is recorded here.

ADR-0004 fixes the simple staged STT -> LLM -> TTS pipeline and the three stable
logical names `stackchan-stt`, `stackchan-chat`, and `stackchan-tts`. REQ-004
requires only the conversation LLM to be a swappable Foundry deployment. The E1
Task and its human review explicitly keep all three names provider-neutral and
allow each to map to a backing service, model, or voice. This ADR therefore
retains the staged pipeline while replacing ADR-0004's provisional assumption
that STT and TTS must also be Foundry model deployments.

Azure catalog, quota, and price facts below are a point-in-time snapshot from
2026-08-01. Later Tasks must use this profile verbatim. If a selected resource,
model version, SKU, quota, role, or price is no longer available, they apply
`needs:replan`; they do not silently substitute another choice.

## Decision

### Deployment boundary, region, naming, and tags

The target is one subscription-scoped `prod` deployment used for development
and production. Every regional resource, including resource-group metadata, is
located in `eastus2`; there is no fallback region. The Cost Management budget is
subscription-scoped and filtered to the one project resource group. Global
model deployment describes inference processing scope, not resource location:
the Foundry account is in East US 2, while a `GlobalStandard` model deployment
may process prompts in any Azure region where that deployment type operates.
This profile makes no Japan or East US 2 data-residency guarantee.

The only resource group is:

`rg-present-stackchan-for-misaki-hbd-v2-prod`

The canonical slug is never shortened in tags. Every taggable resource has:

| Tag | Fixed value |
|---|---|
| `project` | `present-stackchan-for-misaki-hbd-v2` |
| `environment` | `prod` |
| `managed-by` | `bicep` |

Names use `<service>-<canonical-slug>-prod` when Azure accepts that name. For a
globally unique or length-constrained name, Bicep appends the 13-character result
of `uniqueString(subscription().id, canonicalProjectSlug, environment,
serviceCode)` and truncates only the canonical-slug segment from the right to fit
the documented maximum. The resolved subscription identifier and hash are
deployment output and are never committed. Examples below are templates, not
resolved names:

| Resource | Deterministic name template |
|---|---|
| Log Analytics | `log-present-stackchan-for-misaki-hbd-v2-prod` |
| Application Insights | `appi-present-stackchan-for-misaki-hbd-v2-prod` |
| Container Apps environment | `cae-present-stackchan-for-misaki-hbd-v2-prod` |
| Relay managed identity | `id-present-stackchan-for-misaki-hbd-v2-relay-prod` |
| Foundry project | `proj-present-stackchan-for-misaki-hbd-v2-prod` |
| Foundry account | `ai-present-stackchan-for-misaki-hbd-v2-prod-<hash13>` |
| Speech account | `sp-present-stackchan-for-misaki-hbd-v2-prod-<hash13>` |
| Web PubSub | `wps-present-stackchan-for-misaki-hbd-v2-prod-<hash13>` |
| Cosmos DB account | `cos-<truncated-canonical-slug>-prod-<hash13>` |
| Key Vault | `kv-<truncated-canonical-slug>-prod-<hash13>` |

The three logical AI names are contracts and are never hashed or shortened.

### Simplest viable Azure resource profile

All resources except the subscription budget are inside the single resource
group. Public endpoints remain enabled because E1 deliberately has no virtual
network or private endpoints; HTTPS/TLS and Entra authorization provide the
access boundary. Adding network isolation, availability zones, replicas, or a
second region requires new evidence and a superseding decision.

| Component | ARM resource type | Fixed SKU/capacity and configuration |
|---|---|---|
| Resource group | `Microsoft.Resources/resourceGroups` | No SKU; one group, metadata location `eastus2` |
| Log Analytics | `Microsoft.OperationalInsights/workspaces` | `PerGB2018`, 30-day retention, no commitment tier |
| Application Insights | `Microsoft.Insights/components` | Workspace-based `web` component; no separate SKU or classic component |
| Key Vault | `Microsoft.KeyVault/vaults` | `standard`, RBAC authorization, soft delete and purge protection enabled |
| Cosmos DB for NoSQL | `Microsoft.DocumentDB/databaseAccounts` | `Standard` offer with `EnableServerless`, one `eastus2` region, Session consistency, no zone redundancy, no multi-region writes, no free-tier assumption |
| Container Apps environment | `Microsoft.App/managedEnvironments` | Consumption workload profile only; no dedicated profile or zone redundancy |
| Web PubSub | `Microsoft.SignalRService/webPubSub` | `Free_F1`, capacity `1`; 20 concurrent connections and 20,000 messages/day are accepted for one household |
| Foundry account | `Microsoft.CognitiveServices/accounts` | kind `AIServices`, SKU `S0`, `allowProjectManagement=true` |
| Foundry project | `Microsoft.CognitiveServices/accounts/projects` | One child project; no hub, AI Search, storage account, or other optional dependency |
| Chat deployment | `Microsoft.CognitiveServices/accounts/deployments` | `GlobalStandard`, capacity `10`; mapping fixed below |
| Speech account | `Microsoft.CognitiveServices/accounts` | kind `SpeechServices`, SKU `F0`; one account serves both STT and TTS |
| Relay identity | `Microsoft.ManagedIdentity/userAssignedIdentities` | One user-assigned managed identity; no SKU |
| Budget | `Microsoft.Consumption/budgets` | Subscription scope, JPY 2,000 monthly actual-cost budget filtered to the resource group |

Log Analytics receives diagnostics through Azure Monitor diagnostic settings,
not a committed workspace key. Application Insights is linked to that workspace.
The environment itself has no always-on compute charge; the operating estimate
below conservatively includes the later relay workload.

### Fixed logical AI mappings

| Logical name | Backing and explicit version | SKU/capacity | API family and fixed options | Resource location / processing scope |
|---|---|---|---|---|
| `stackchan-chat` | Foundry deployment of OpenAI `gpt-5.6-luna`, version `2026-07-09` | `GlobalStandard`, capacity `10` | Azure OpenAI v1 Responses API, `POST /openai/v1/responses`; Entra bearer token | Foundry account in `eastus2`; Global deployment processing is not restricted to East US 2 |
| `stackchan-stt` | Azure Speech real-time base speech-to-text service; customer-selectable model version: none (Microsoft-managed); locale `ja-JP` | Shared Speech `F0`; 5 audio hours/month; one concurrent real-time base-model request | Speech SDK real-time recognition or short-audio REST `cognitiveservices/v1`; language `ja-JP`; Entra token | Regional Speech account and processing in `eastus2` |
| `stackchan-tts` | Azure Speech Standard neural voice `ja-JP-NanamiNeural`; customer-selectable voice version: none (Microsoft-managed) | Shared Speech `F0`; 0.5 million neural characters/month; 20 transactions/60 seconds | Text-to-speech REST `cognitiveservices/v1` or Speech SDK; SSML voice fixed to `ja-JP-NanamiNeural`; Entra token | Regional Speech account and processing in `eastus2` |

`stackchan-chat` is an actual Foundry deployment name. `stackchan-stt` and
`stackchan-tts` are application configuration aliases for two capabilities of
the same Speech resource; Azure Speech does not expose customer-named base-model
deployments for these selected capabilities. This is the deliberate refinement
of ADR-0004 described above, not a change to the staged pipeline or device
protocol. All aliases, endpoints, locale, and voice values are hot-swappable
proxy configuration, preserving REQ-004's no-firmware-change rule.

The chat model is the current GA default in the approved subscription's East US
2 catalog, supports Responses and Chat Completions, has 10,000 quota units and
10,000 available capacity with zero current use, and has a current default
deployment capacity of 10. Microsoft's model retirement schedule lists
2027-07-09 for this version, before the final gift date, so the stable logical
deployment name is also the migration boundary: before retirement, a separately
approved current version must replace the backing model without firmware change.
Automatic version upgrades are not assumed.

Speech `F0` is selected because Microsoft documents `ja-JP` real-time
transcription, the `ja-JP-NanamiNeural` standard voice, the required one-device
capacity, and hard monthly free allowances. The subscription read-only SKU check
listed `F0` in `eastus2`, and no existing Speech F0 resource was found. If that
single free allocation is unavailable at deployment time, Tasks stop for
replanning instead of silently selecting paid `S0`.

The Foundry alternatives were considered but not selected:

- `gpt-live-transcribe` was GA in the live East US 2 catalog as version
  `2026-07-28`, `GlobalStandard` capacity 10, with matching quota and available
  capacity. On 2026-08-01 Microsoft had no corresponding Azure Retail Prices
  meter, the current Microsoft Realtime REST reference did not yet list it, and
  production-like Japanese evidence was still required. Direct OpenAI pricing
  is not Azure pricing. It therefore fails this Task's deterministic Azure
  price/API evidence bar.
- `gpt-realtime-whisper` version `2026-05-06` was documented and priced at
  JPY 164.9697/audio hour, but adds a paid realtime WebSocket session where the
  mature Speech F0 capability satisfies the same staged STT contract.

All regional calls after device ingress remain inside East US 2. A device in
Japan still incurs a cross-Pacific path to the relay; this profile neither
asserts nor guarantees REQ-003 latency. E4 must measure the complete staged path
with production-like Japanese audio.

### Foundry account and project arrangement

There is one `AIServices` account and one child project in the project resource
group. The account owns the `stackchan-chat` deployment; the project is the
single management grouping for that account and deployment. There is no separate
hub, project-managed network, AI Search instance, storage account, connection
resource, or second Foundry account. The relay calls the account's Azure OpenAI
endpoint directly with its managed identity. The Speech account is separate
because its `F0` SKU and regional speech endpoints are not Foundry model
deployment SKUs.

### Runtime managed identity, RBAC, and local authentication

E1 creates one user-assigned identity for the future relay proxy. Assignments
are data-plane roles at the narrowest stable resource scope; the identity gets
no subscription, resource-group, `Owner`, `Contributor`, or control-plane
resource-management role.

| Relay operation | Exact built-in role | Exact scope |
|---|---|---|
| Call `stackchan-chat` | `Cognitive Services OpenAI User` | Foundry `AIServices` account |
| Call Speech STT/TTS | `Cognitive Services Speech User` | Speech account |
| Read runtime secrets | `Key Vault Secrets User` | Project Key Vault; vault scope is required because concrete secrets are created later |
| Read/write settings and conversation data | `Cosmos DB Built-in Data Contributor` (data-plane role ID `00000000-0000-0000-0000-000000000002`) | `/dbs/stackchan` within the project Cosmos account |
| Negotiate clients and publish Web PubSub messages | `Web PubSub Service Owner` | Project Web PubSub resource |
| Send authenticated application telemetry | `Monitoring Metrics Publisher` | Application Insights component |

Cosmos DB's assignment is a Cosmos native data-plane SQL role assignment, not an
Azure RBAC role assignment. The stable complete built-in role ID is documented
by Microsoft; infrastructure must use that published ID without copying any
subscription-specific prefix.

The later management API is a separate Container App with a separate managed
identity. It needs Key Vault, Cosmos DB, Web PubSub, and Application Insights
access but no Foundry or Speech role unless a later accepted requirement proves
otherwise. E1 creates only the relay identity; E5 owns the management identity
and its assignments.

| Service | Local/key authentication decision |
|---|---|
| Foundry `AIServices` | `disableLocalAuth=true`; Entra only |
| Speech | Custom subdomain configured for Entra; `disableLocalAuth=true`; no Speech key use |
| Key Vault | `enableRbacAuthorization=true`; no access policies; local key authentication is not applicable |
| Cosmos DB | `disableLocalAuth=true`; primary/secondary keys are unusable |
| Web PubSub | `disableLocalAuth=true`, `disableAadAuth=false`; access keys are unusable |
| Application Insights | `DisableLocalAuth=true`; managed-identity telemetry only |
| Log Analytics | `features.disableLocalAuth=true`; diagnostic settings do not use a committed shared key |
| Resource group, Container Apps environment, managed identity, budget | No applicable data-plane local-key switch |

Disabling service keys does not remove the need for application-level device and
administrator authentication described in ADR-0003 and ADR-0005.

### Configuration and secret boundary

No real value from this table is committed to the repository.

| Value class | Store | Rule |
|---|---|---|
| Administrator LINE user-ID allowlist | Cosmos DB `stackchan` database/settings container | Authorization configuration and personal data, not a credential; admin-only access |
| LINE channel ID/audience, LIFF ID, feature flags, and ordinary settings | Cosmos DB settings | Non-secret configuration; values are environment-specific and absent from source control |
| Logical AI names, endpoints, `ja-JP`, and `ja-JP-NanamiNeural` | Container App non-secret configuration generated by infrastructure | Contracts may be committed; resolved endpoints are deployment output |
| LINE channel secret and Messaging API channel access token | Key Vault | Secret references only in Container App configuration |
| Per-device keys and later APNs signing material | Key Vault | One independently revocable secret per credential; never in firmware source or Cosmos DB |
| LINE ID tokens and Azure access tokens | Nowhere persistent | Short-lived request credentials; validate/use in memory and discard |
| Budget notification recipient | Private secure deployment-time parameter | Passed directly to the budget contact list; not stored as an app secret or committed value |

### Management API hosting assumption

E5 hosts the management API as a separate Container App in the same Consumption
Container Apps environment as the relay. It uses external HTTPS ingress and may
scale to zero initially. It does not get a separate environment, App Service
plan, API Management instance, or high-availability footprint. E1 provisions
only the shared environment and observability dependencies; it does not create
or implement the management API.

### Budget and operating-cost envelope

The budget is a subscription-scope `Microsoft.Consumption/budgets` resource
filtered by `ResourceGroupName` to
`rg-present-stackchan-for-misaki-hbd-v2-prod`:

| Field | Fixed value |
|---|---|
| Amount and currency | `2000` JPY; currency is inherited from the subscription billing account and deployment preflight must confirm `JPY` |
| Time grain | `Monthly` |
| Cost basis / threshold type | Actual cost / `Actual` |
| Notifications | Enabled at `50`, `80`, and `100` percent with `GreaterThanOrEqualTo` |
| Nominal alert amounts | JPY 1,000, JPY 1,600, and JPY 2,000 |
| Recipient | Required secure string deployment parameter, used only in `contactEmails` |
| Action groups | None |

The budget start date is the first UTC day of the deployment month and is a
non-secret deployment parameter because the API constrains valid start dates.
No email address, action-group ID, subscription ID, tenant ID, or credential is
present in source or committed parameter files. A budget notification is an
eventual alert, not a spending cap or automatic shutdown.

The following conservative monthly envelope uses 2026-08-01 East US 2 JPY
retail rates and does not rely on subscription-shared Container Apps or Log
Analytics free grants:

| Assumption | Estimated JPY/month |
|---|---:|
| One later relay replica idle all month at 0.25 vCPU / 0.5 GiB on Consumption | 971 |
| `gpt-5.6-luna`, short-context Global Standard: 0.3M input + 0.1M output tokens | 146 |
| Speech STT <= 5 audio hours and neural TTS <= 0.5M characters on the one F0 account | 0 |
| Cosmos serverless: 1M RU + 1 GiB storage | 81 |
| Key Vault Standard: 10,000 operations | 5 |
| Log Analytics/Application Insights: 0.25 GiB billable ingestion | 112 |
| Web PubSub Free_F1, Foundry S0 account, workspace-based Application Insights, identity, and budget base charges | 0 |
| **Illustrative total** | **1,315** |

This is a target envelope, not a guarantee. Short-context chat, telemetry
sampling, the Speech F0 allowances, serverless Cosmos usage, and management API
scale-to-zero are operating assumptions. Network egress, burst compute, model
price changes, quota overruns, and higher logging remain in the approximately
JPY 685 headroom and can cross the budget. Cost alerts and the monthly report
are the feedback loop; breaching 80% requires an operator review before adding
capacity or changing SKU.

### Point-in-time evidence and deployment gates

Read-only checks against the privately approved local-default subscription on
2026-08-01 produced the following redacted results. They made no Azure mutation.

| Check | Redacted result |
|---|---|
| Subscription context | Enabled and local-default; Cost Management billing currency `JPY` |
| Regional providers | East US 2 listed for every selected regional resource provider/type |
| Chat catalog | `gpt-5.6-luna` `2026-07-09`, GA/default, Responses + Chat Completions, `GlobalStandard` default capacity 10 |
| Chat quota/capacity | quota 10,000, current use 0; live available capacity 10,000 |
| Speech | `SpeechServices` `F0` offered in East US 2; no existing Speech F0 resource observed |
| Web PubSub | `Free_F1` offered; no existing East US 2 Free_F1 resource observed |
| Billing meters | JPY retail meters present for the selected chat model and every usage-priced component in the estimate |
| Rejected live STT candidate | Catalog/quota/capacity present, but no Azure Retail Prices meter found for `gpt-live-transcribe` |

The live deployment Task repeats these checks immediately before `what-if` and
deployment. It must also prove Entra calls to all three logical contracts with
redacted evidence and no service key.

## Consequences

- Easier: every regional resource is colocated, there is one resource group,
  one observability workspace, one Foundry account/project, one Speech account,
  and one Container Apps environment; names and runtime roles are deterministic.
- Easier: the Speech F0 account provides documented Japanese STT and TTS with
  no modeled monthly charge and avoids binding firmware to a provider.
- Harder: public service endpoints remain reachable at the network layer, so
  keyless Entra authorization and application authentication must be tested and
  monitored carefully.
- Harder: Speech F0 has non-adjustable one-request STT concurrency and limited
  TTS throughput. This is accepted for one device/household; evidence of
  throttling triggers replanning, not an automatic paid-SKU upgrade.
- Harder: Global Standard Foundry inference can process outside East US 2, and
  the Japan-to-East-US-2 path may miss REQ-003. E4 measurement remains decisive.
- The selected model and prices are time-sensitive. REQ-004's stable logical
  name is the controlled migration seam, not permission for a silent model
  substitution.

## References

- `docs/agreements/requirements.md` — REQ-003, REQ-004, REQ-006, REQ-014,
  REQ-015, REQ-016, REQ-017
- ADR-0002 (overall architecture), ADR-0003 (device-proxy protocol), ADR-0004
  (staged audio pipeline), ADR-0005 (LINE allowlist)
- [Task #31 and human decisions](https://github.com/mrmo-sandbox/present-stackchan-for-misaki-hbd-v2/issues/31)
- [Foundry model catalog and versions](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/models-sold-directly-by-azure?pivots=azure-openai)
- [Foundry model regional availability](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/models-sold-directly-by-azure-region-availability)
- [Azure OpenAI model retirement schedule](https://learn.microsoft.com/en-us/azure/foundry/openai/concepts/model-retirement-schedule)
- [Foundry deployment types and processing scope](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types)
- [Foundry models list API](https://learn.microsoft.com/en-us/rest/api/aiservices/accountmanagement/models/list)
- [Foundry location model-capacity API](https://learn.microsoft.com/en-us/rest/api/aifoundry/accountmanagement/location-based-model-capacities/list)
- [Azure OpenAI quota](https://learn.microsoft.com/en-us/azure/foundry/openai/quotas-limits)
- [Azure OpenAI v1 API lifecycle](https://learn.microsoft.com/en-us/azure/foundry/openai/api-version-lifecycle)
- [Foundry Realtime API reference](https://learn.microsoft.com/en-us/rest/api/aifoundry/azureopenai/realtime)
- [Foundry resource and project Bicep arrangement](https://learn.microsoft.com/en-us/azure/foundry/how-to/create-resource-template)
- [Log Analytics workspace resource reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces)
- [Application Insights component resource reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/components)
- [Key Vault resource reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults)
- [Cosmos DB account resource reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/databaseaccounts)
- [Container Apps environment resource reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments)
- [Web PubSub resource reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.signalrservice/webpubsub)
- [Azure AI services account resource reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts)
- [Azure Speech regions](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/regions)
- [Azure Speech language and voice support](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/language-support)
- [Azure Speech pricing](https://azure.microsoft.com/en-us/pricing/details/speech/)
- [Azure Speech quotas and limits](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-services-quotas-and-limits)
- [Azure Speech Entra authentication](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/how-to-configure-azure-ad-auth)
- [Azure speech-recognition and generation technology choice](https://learn.microsoft.com/en-us/azure/architecture/data-guide/ai-services/speech-recognition-generation)
- [Disable local authentication for Azure AI services](https://learn.microsoft.com/en-us/azure/ai-services/disable-local-auth)
- [Key Vault RBAC roles](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide)
- [Cosmos DB data-plane RBAC](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/security/reference-data-plane-roles)
- [Web PubSub managed-identity authorization](https://learn.microsoft.com/en-us/azure/azure-web-pubsub/howto-authorize-from-managed-identity)
- [Container Apps pricing](https://azure.microsoft.com/en-us/pricing/details/container-apps/)
- [Web PubSub pricing](https://azure.microsoft.com/en-us/pricing/details/web-pubsub/)
- [Cosmos DB pricing](https://azure.microsoft.com/en-us/pricing/details/cosmos-db/)
- [Key Vault pricing](https://azure.microsoft.com/en-us/pricing/details/key-vault/)
- [Azure Monitor pricing](https://azure.microsoft.com/en-us/pricing/details/monitor/)
- [Azure Retail Prices API](https://prices.azure.com/api/retail/prices)
- [Cost Management budget with Bicep](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/quick-create-budget-bicep)
- [Consumption budget resource](https://learn.microsoft.com/en-us/azure/templates/microsoft.consumption/budgets)
