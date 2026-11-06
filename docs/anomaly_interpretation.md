# Interpreting anomalies without inventing causes

Reviewed on 6 November 2026. Evidence comes from the executed
[analysis notebook](../notebooks/01_data_analysis.ipynb), the supplied case-study
brief and the sources below. The brief calls the inputs dummy data. No data
generator, correction log or explanation of individual anomalies is provided.
Consequently, an external report can support plausibility but cannot establish
what happened in a particular source row.

## What the additional checks answer

| Question | Direct evidence from this dataset | What remains unresolved |
| --- | --- | --- |
| Is the high North Africa AOV simply normal for that destination/season? | The EUR 8,394 historical AOV is 8.39 times the leave-one-out ticket-weighted median of 57 other North Africa records in the same flight quarter | Duration, hotel category and the generator could explain differences; no cause is confirmed |
| Are unusually low prices explained by comparing cheap and expensive markets? | The EUR 50 Mallorca AOV is only 0.08 times its same-quarter peer median | Its validity, accounting treatment and product attributes are unknown |
| Do anomalies disappear when summarised by market? | Hypothetically omitting all historical review flags changes North Africa AOV by -1.59%; the equivalent Canaries change is -0.75% | These are influence diagnostics, not an estimate of the correct AOV |
| Are zero revenues confined to a single batch or market? | Sixteen actual rows cover four markets and both booking years, representing 41 travellers | Spread alone does not distinguish missing prices, adjustments, free products or generated edge cases |
| Is 31 December inherently inactive? | Historical bookings on that date represent 57 travellers in 2024 and 18 in 2025 | This does not specify the missing 2026 booking target or prove a file omission |
| Is the overall AOV/lead-time relationship only a different destination/season mix? | On the same paired cohort, the long-minus-short AOV gap falls from EUR 185.55 to EUR 135.33 when both groups use the same market/month weights | The remaining association is not a causal effect; product quality, duration and other features are missing |
| Can all joint-cell AOVs be forced into the exploratory EUR 100–5,000 range? | Five zero-revenue and two high-AOV forecast targets lie outside it | Such a universal bound contradicts those exact targets; feasible exceptions or revised requirements need an explicit decision |
| Are fractional tickets just irregular decimal values? | A near-one factor per month can reconstruct all 1,045 August–December booking rows under two-decimal half-up rounding | The original factors, integer counts, rounding convention and reason for adjustment are not identified |
| Do forecast zero revenues directly repeat historical zero rows? | Same-market calendar-year and 52-week alignments one/two years back find no matches | Other relationships remain possible; no lineage or booking identifiers are supplied |

Peer comparisons stay within a dataset. Actuals use flight year/quarter;
forecasts use their own date year/quarter. Each candidate is omitted from its
peer pool. There must be at least 20 quarter peers, otherwise the pool broadens
to that market's other dates in the same dataset. All ten current candidates
have enough quarter peers. Future flight cohorts remain partially observed.
No confidence level or probability of error is attached to these ratios.

The mix comparison uses 2025 departures observed within the last 365 booking
days, comparing 0–30 with 91–365 days. Sixty-one paired market/month strata
contain 13,530 of 14,886 selected travellers. Each group must have at least five
rows and ten travellers per stratum. Combined group ticket shares supply common
weights. This is a project-specific descriptive diagnostic, not a fitted causal
model, a copy of another paper's estimator or a correction to the source data.

## What the research contributes

The [research review](literature_review.md#follow-up-interpreting-anomalies)
adds P14–P16: a package-price study, a contextual-anomaly survey and a hotel-data
article. These motivate peer comparisons and identify missing explanatory fields.
Their observational units and prices differ from this case study. They do not
authorise deleting unusual rows, importing another dataset's price limits or
claiming that refunds caused our zero revenues.

## Industry evidence and its limits

1. **Eurowings, 13 June 2024:** the summer schedule allowed bookings from
   17 June 2024 through departures on 25 October 2025. The implied maximum
   advance window is 495 days. This is a counterexample to a universal 365-day
   flight-booking limit, not proof about any specific package or dummy row.
   [Official announcement](https://newscloudbusiness.eurowings.com/en/ready-for-summer-2025/).
2. **DRV, 3 March 2025:** its market report describes earlier purchasing,
   different destination demand and moving Easter effects. This provides
   commercial context for studying timing and season separately. Its distribution
   coverage differs from this case study; it cannot explain our anomalies or
   supply calibration targets.
   [Official report](https://www.drv.de/anzeigen/txnews/so-macht-deutschland-2025-urlaub.html).

No 2026 market outcome is used as information that would have been known before
the 2026 forecast year. These sources inform descriptive plausibility only.

## Questions that would resolve the uncertainty

- Obtain the generator/field definitions and confirmation of intentional edge cases.
- For real data, request stable booking IDs, status/amendment history, revenue
  definitions and audit trails; duration, hotel class, board basis and room type
  would make price comparisons more meaningful.
- Confirm forecast market/date scope, including Nordics and 31 December.
- Confirm whether on-books amounts are fixed and whether flight forecasts are
  final or incremental; this determines how to handle the two local conflicts.
- Specify how zero-revenue and high-AOV marginal targets should interact with
  realistic joint-cell AOV requirements.

The current treatment is to preserve sources and target forecasts, retain review
candidates in main summaries, and exclude only the negative lead-time row from
timing analysis. Hypothetical exclusions remain clearly separate diagnostics.

Monthly scaling is another sensitivity hypothesis, not a correction. Holding
revenue fixed while substituting inferred integer tickets does not show that
revenue was unchanged in generation. In particular, the North Africa example's
AOV would rise from EUR 9,513.04 to EUR 9,846, leaving its extreme value unresolved.
