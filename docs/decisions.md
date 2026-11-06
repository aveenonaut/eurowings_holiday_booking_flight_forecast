# Analysis decisions and open questions

Recorded on 6 November 2026. These concern descriptive analysis, not a chosen
forecasting method or permission to change source data.

| Decision | Reason | Scope |
| --- | --- | --- |
| Read the existing raw SQL tables | Keep a single queryable ingestion layer | Analysis input; source CSVs remain immutable |
| Keep exact Decimal source totals | Avoid floating-point drift in source comparisons | Floating-point copies are used only for descriptive calculations and plotting |
| Weight lead-time summaries by Tix | Rows represent different traveller amounts | These are descriptive traveller distributions, not independent experimental samples |
| Use summed Revenue / summed Tix for group AOV | An unweighted mean of row ratios gives the wrong group ratio | All market/lead-band summaries |
| Exclude one negative-lead observation from timing charts only | A flight one day before booking is not a valid ordinary lead time | 1 row, 2 travellers, EUR 350; retained in raw totals and tables |
| Retain zero revenues and fractional forecast ticket amounts | Their business meaning is unresolved; forecasts are expected amounts | No cleaning or rounding |
| Treat monthly near-one scaling as a tested construction hypothesis | Factor intervals can reconstruct all August–December booking Tix, but do not identify the original process | Exact Decimal rounding checks; inferred integers do not replace forecast targets |
| Keep cross-file zero-revenue linkage claims limited to tested rules | Same market/count alone does not establish identity and no booking IDs are available | Calendar-year and 52-week alignment tests report zero matches, not proof of independence |
| Treat extreme AOV, high row volume and long lead times as review flags | Exploratory thresholds do not establish invalid records; there are no booking IDs or holiday-duration fields | Main summaries retain these rows; hypothetical omissions appear only in a separate sensitivity table |
| Compare candidate prices with leave-one-out market/quarter peers in the same dataset | A global price threshold ignores context; forecasts have a different grain | At least 20 quarter peers, otherwise same-market fallback; no cause or significance claim |
| Compare lead-group AOV with common market/month weights | Destination/season composition can contribute to aggregate differences | Paired 2025 departure strata only; observational diagnostic with sample counts |
| Restrict the illustrative annual balance to shared forecast markets | The full historical population includes Nordics with no forecast target | Full historical totals stay visible; daily missing scope remains unresolved |
| Do not convert review AOV cutoffs into universal joint-cell bounds | Seven supplied forecast margins already lie outside the illustrative interval | Necessary-condition diagnostic; preserve zero/high-AOV targets |
| Treat external reports as plausibility evidence | The brief specifies dummy data and supplies no generating process | Individual anomaly causes remain unknown |
| Treat absent forecast keys as unspecified during EDA | Zero and missing scope have different modelling implications | No automatic zero-filled forecast constraints |
| Compare fixed booking-lookback windows | Boundary cohorts do not contain complete lifetime booking histories | Last-365-day and last-180-day summaries are sensitivity views, not bias corrections |
| Do not change observed on-books amounts or forecast targets | Local conflicts need a business interpretation first | No clipping, negative residual replacement or forecast normalisation |
| Do not fit a model or report forecast accuracy yet | The target population and feasible constraints need definition | EDA branch |

The source booking-date bounds are used to define observation-window diagnostics.
They are not asserted to be the company's official extraction date or a guarantee
that all records within those dates are present.

Open questions and evidence are listed in [the findings report](../reports/findings.md).
Candidate method families and the limits of applying published results to this
case study are documented in [the research review](literature_review.md).
