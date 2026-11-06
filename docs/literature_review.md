# Research review for booking-to-flight analysis

Reviewed on 6 November 2026. The immediate purpose is to decide what to examine
in the data, not to select a model before looking at the evidence.

## Scope and reading depth

This review covers **16 distinct research papers**. Relevant sections of 14
accessible full texts were consulted, focusing on their problem definitions,
assumptions, methods and evaluation. For P01 and P02, only the university
catalogue/abstract and indexed excerpts were accessible; their PDF downloads
failed. Those two are explicitly marked as partial reviews. No claim is made
to have checked every proof or independently reproduced any paper's results.

Only primary papers, author manuscripts and university publication records are
used below. PDFs are linked rather than copied into the repository. Publication
years and manuscript years can differ; preprint versions are identified.

## Booking patterns and aggregation

### P01. Weatherford and Kimes (2003) — partial review

[A Comparison of Forecasting Methods for Hotel Revenue Management](https://ecommons.cornell.edu/entities/publication/046131d9-289a-4ee2-8249-23c59a5362f0).
International Journal of Forecasting 19(3), 401–415.

- **Reviewed:** university abstract and bibliographic record; full PDF unavailable.
- **Finding:** comparisons across hotel datasets did not establish one universal
  winning technique; simple pickup and smoothing methods performed well in
  parts of the study.
- **EDA implication:** inspect booking pace and lead-time distributions before
  selecting a complicated method. Record the available history and granularity.
- **Limit:** forecasting hotel arrivals is related to, but does not solve, our
  fixed booking-date and flight-date allocation problem.

### P02. Weatherford, Kimes and Scott (2001) — partial review

[Forecasting for Hotel Revenue Management: Testing Aggregation Against Disaggregation](https://ecommons.cornell.edu/entities/publication/f926819b-16db-4b95-b97f-d6807d50b751).
Cornell Hotel and Restaurant Administration Quarterly.

- **Reviewed:** university record, publisher summary and indexed paper excerpts;
  full PDF unavailable.
- **Finding:** the level at which demand is analysed and forecast matters.
- **EDA implication:** compare destination markets, not just overall totals;
  quantify how little evidence the smallest markets contain before splitting
  them into further seasonal groups.
- **Limit:** this does not imply that the finest possible segmentation is best
  for our small dataset.

### P03. van Leeuwen and Koole (2021 manuscript)

[Demand forecasting in hospitality using smoothed demand curves](https://arxiv.org/abs/2102.04236).
arXiv:2102.04236, revised manuscript v2; subsequently published in 2022.

- **Reviewed:** data, seasonality, booking/arrival weekday patterns, lead-time
  analysis, smoothing model and evaluation sections of the full text.
- **Finding:** demand timing can depend on time to arrival and calendar patterns;
  transparent curves can inform decision-making.
- **EDA implication:** examine ticket-weighted lead times by market, flight
  season and year; separate booking-date seasonality from flight-date seasonality.
- **Limit:** their cancellation/status and pricing fields are absent here. Do
  not copy their exclusions of zero-price stays or their hotel revenue gains.

## Coherent forecasts and constraints

### P04. Hyndman, Ahmed, Athanasopoulos and Shang (2011)

[Optimal combination forecasts for hierarchical time series](https://www.robjhyndman.com/papers/Hierarchical6.pdf).
Computational Statistics & Data Analysis 55(9), 2579–2589; linked author manuscript.

- **Reviewed:** hierarchy definitions, aggregation approaches, regression-based
  reconciliation and tourism application.
- **Finding:** independently produced forecasts need not add up; aggregation
  relationships should be stated explicitly.
- **EDA implication:** write down the required daily/market totals and inspect
  compatibility at market and calendar boundaries.
- **Limit:** the method adjusts base forecasts. Our supplied forecasts must be
  preserved, so it is background rather than an automatic solution.

### P05. Wickramasuriya, Athanasopoulos and Hyndman (2019)

[Optimal forecast reconciliation for hierarchical and grouped time series through trace minimization](https://robjhyndman.com/papers/MinT.pdf).
Journal of the American Statistical Association; linked earlier author manuscript.

- **Reviewed:** grouped-series formulation, covariance-based objective and
  covariance estimation discussion.
- **Finding:** error dependencies matter for statistical reconciliation.
- **EDA implication:** distinguish accuracy against held-out observations from
  agreement with supplied totals; record whether forecast residual histories exist.
- **Limit:** we do not have a history of supplied forecast errors. MinT neither
  preserves all given marginals by default nor guarantees nonnegative values.

### P06. Athanasopoulos, Hyndman, Kourentzes and Panagiotelis (2024)

[Forecast reconciliation: A review](https://robjhyndman.com/papers/hf_review.pdf).
International Journal of Forecasting 40(2), 430–456; linked 2023 manuscript.

- **Reviewed:** grouped versus nested structures, linear constraints,
  nonnegativity, temporal reconciliation and evaluation discussion.
- **Finding:** coherence, uncertainty and predictive accuracy are related but
  separate requirements; extra constraints may require constrained optimisation.
- **EDA implication:** list feasibility restrictions explicitly, including
  chronology, nonnegativity and revenue/ticket support.
- **Limit:** booking date and flight date are two event dates, not merely daily
  and monthly aggregations of the same time axis.

### P07. Girolimetto, Athanasopoulos, Di Fonzo and Hyndman (2024)

[Cross-temporal probabilistic forecast reconciliation: Methodological and practical issues](https://arxiv.org/abs/2303.17277).
International Journal of Forecasting 40(3), 1134–1151; linked 2023 manuscript v3.

- **Reviewed:** framework, multi-step/overlapping residuals, uncertainty and
  tourism evaluation sections.
- **Finding:** reconciliation and evaluation should respect the relevant time
  scales; long-horizon error estimation needs appropriate evidence.
- **EDA implication:** report daily support but also inspect weekly/monthly
  patterns and how much history remains after respecting observation boundaries.
- **Limit:** cross-temporal reconciliation is not the same as linking booking
  and flight dates; its probability models are not adopted here.

## Allocating a joint table to fixed totals

### P08. Pukelsheim (2014)

[Biproportional scaling of matrices and the iterative proportional fitting procedure](https://www.math.uni-augsburg.de/htdocs/emeriti/pukelsheim/2014b.pdf).
Annals of Operations Research 215, 269–283.

- **Reviewed:** matrix fitting problem, existence conditions and limiting error.
- **Finding:** matching both sets of marginals requires feasible totals and
  support; more iterations cannot repair an infeasible problem.
- **EDA implication:** compare booking/flight totals by market and identify
  flows outside 2026 before attempting to fit a within-year matrix.
- **Limit:** this is a single nonnegative measure. It does not ensure realistic
  AOV when tickets and revenue are allocated independently.

### P09. Idel (2016)

[A review of matrix scaling and Sinkhorn's normal form for matrices and positive maps](https://arxiv.org/abs/1609.06349).
arXiv:1609.06349, review preprint.

- **Reviewed:** prescribed row/column sums, support/existence conditions,
  entropy interpretation and the RAS algorithm.
- **Finding:** allowed nonzero cells are central to whether scaling is possible.
- **EDA implication:** distinguish impossible date pairs from unobserved ones.
  A cell absent from two years of sparse history is not automatically impossible.
- **Limit:** adding small positive values everywhere would also permit impossible
  chronology; any later smoothing must respect an explicitly allowed support.

### P10. Brossard and Leuridan (2016; arXiv revision 2018)

[Iterated proportional fitting procedure and infinite products of stochastic matrices](https://arxiv.org/abs/1606.09126).
arXiv:1606.09126, v2.

- **Reviewed:** fitting procedure, support restrictions, convergence and the
  incompatible-marginal case.
- **Finding:** alternating row/column fits can fail to converge to a common
  solution when the allowed cells cannot carry the required totals.
- **EDA implication:** inspect zero/absent cells and the chronological support;
  identify negative residual requirements under a fixed-on-books interpretation.
- **Limit:** historical observations need interpretation before they are declared
  fixed allocations. This paper does not determine that business interpretation.

### P11. Cuturi (2013)

[Sinkhorn Distances: Lightspeed Computation of Optimal Transportation Distances](https://arxiv.org/abs/1306.0895).
NeurIPS 2013; linked author preprint.

- **Reviewed:** transportation tables, fixed marginals, entropic regularisation
  and matrix scaling formulation.
- **Finding:** a joint allocation can be constrained to given marginals while
  using a cost or regularisation to prefer certain allocations.
- **EDA implication:** measure plausible lead-time ranges and historical shapes
  before constructing any allocation preference or cost.
- **Limit:** normalising the two annual forecasts separately would conceal their
  different total amounts. This paper does not specify cross-year boundary flows
  or jointly couple ticket and revenue allocations for this assignment.

## Evaluation and honest uncertainty

### P12. Hyndman and Koehler (2006)

[Another look at measures of forecast accuracy](https://robjhyndman.com/papers/mase.pdf).
International Journal of Forecasting 22(4), 679–688; linked earlier manuscript.

- **Reviewed:** zero/near-zero behaviour of percentage errors, scaled errors and
  benchmark comparisons.
- **Finding:** common percentage error measures can break down with zero or
  small denominators; scaled measures also need valid reference scales.
- **EDA implication:** count sparse/zero cells before choosing metrics. Later
  report errors in ticket/euro units and examine denominators of relative scores.
- **Limit:** EDA has no fitted model and no held-out predictions, so it cannot
  honestly report forecast MAE, MASE or similar performance scores yet.

### P13. Hewamalage, Ackermann and Bergmeir (2023)

[Forecast evaluation for data scientists: common pitfalls and best practices](https://arxiv.org/abs/2203.10716).
Data Mining and Knowledge Discovery; linked 2022 manuscript v2.

- **Reviewed:** data partitioning, forecast origins, leakage, benchmarks and
  metric selection.
- **Finding:** preprocessing and evaluation can leak future information, and
  benchmark/metric choices must fit the forecasting horizon and data.
- **EDA implication:** distinguish descriptive use of all observations from
  later training. Propose date-based evaluation with features estimated using
  only information available at each simulated forecast origin.
- **Limit:** matching held-out margins is a conditional allocation experiment;
  if those margins are supplied as truth it is not an end-to-end forecast test.

## Follow-up: interpreting anomalies

### P14. Henn, Islam, Schwind and Wieland (2020)

[Measuring price dynamics of package holidays with transaction data](https://www.bundesbank.de/resource/blob/831748/97956ad6c1594d083d01ece3ef366fe6/472B63F073F071307366337C94F8C870/2020-04-28-dkp-24-data.pdf).
Deutsche Bundesbank Discussion Paper 24/2020. The related EURONA article is
the same research contribution, not a second paper in this count.

- **Reviewed:** full-text sections 3, 4.1–4.3 and variable definitions.
- **Finding:** product composition can change average package prices without
  a like-for-like price change; their data contain richer holiday attributes.
- **EDA implication:** compare AOV within market/season and show a common-mix
  sensitivity comparison rather than explaining price solely through lead time.
- **Limit:** their price filters are per person per day. Our AOV lacks duration,
  so their cutoffs cannot be transferred or used to diagnose our dummy rows.

### P15. Chandola, Banerjee and Kumar (2009)

[Anomaly Detection: A Survey](https://arindam.cs.illinois.edu/papers/09/anomaly.pdf).
ACM Computing Surveys 41(3), Article 15, DOI 10.1145/1541880.1541882.

- **Reviewed:** full-text sections 1.1–1.2, 2.2 and 10.1.
- **Finding:** an observation can be unusual only within a particular context;
  anomaly detection is distinct from simply removing noise.
- **EDA implication:** compare flagged AOVs with peers in the same dataset,
  market and calendar quarter, leaving each candidate out of its own peers.
- **Limit:** peer ratios and arbitrary screening thresholds do not identify
  causal mechanisms, demonstrate fraud or establish that data should be deleted.

### P16. Antonio, de Almeida and Nunes (2019)

[Hotel booking demand datasets](https://pmc.ncbi.nlm.nih.gov/articles/PMC6297060/).
Data in Brief 22, 41–49, DOI 10.1016/j.dib.2018.11.126; online in 2018.

- **Reviewed:** full-text data extraction, Table 1, Tables 4/7 and operational caveats.
- **Finding:** the published hotel datasets include zero ADR, long lead times,
  cancellation status, amendments and stay-length information.
- **EDA implication:** retain unusual values for investigation and record which
  business fields would be needed to interpret them.
- **Limit:** hotel ADR is revenue per staying night, not our package AOV. These
  data neither prove our zero revenues valid nor show why any dummy row occurred.

Haensel and Koole's booking-horizon paper was also located during the follow-up,
but the author PDF returned HTTP 403. It is not counted as an additional
full-text review. Industry announcements are documented separately in
[anomaly interpretation](anomaly_interpretation.md), not counted as papers.

## How this changes our analysis

The following are our project-specific deductions, not claims that any one
paper has solved this exact case study.

| Question | Analysis to perform | Main references |
| --- | --- | --- |
| Are inputs reliable and comparable? | Grain, types, coverage, duplicate keys, zero revenue, negative lead times | P01–P03 |
| When do travellers book? | Ticket-weighted lead-time quantiles and distributions by market/season | P03 |
| Which cohorts are only partly observed? | Booking/flight observation window, cross-year table, fixed lookback sensitivity | P03, P07, P13 |
| How sparse are potential patterns? | Market counts, daily calendar support and month-pair support | P02, P09, P10 |
| Do both forecasts describe the same enclosed population? | Daily/market coverage and annual marginal gaps | P04, P06, P08 |
| Can prior-year bookings be fixed? | On-books amounts versus forecast at each flight date/market, including absent keys | P08, P10 |
| Is revenue behaviour sensible? | Ratio of summed revenue to summed tickets by market and lead time | P03, P06, P08 |
| What can a later model be tested against? | Observation-aware temporal split proposal; no accuracy claims yet | P12, P13 |
| Are price flags still unusual among similar records? | Leave-one-out market/quarter peer AOV and market-level sensitivity | P14, P15 |
| Could product composition explain part of the AOV/lead association? | Common market/month weights on paired 2025 departure strata | P14 |
| Can external evidence establish a row's cause? | Separate observed facts, plausible mechanisms and missing fields | P15, P16 |

Ticket weighting matters because a row can represent multiple travellers. AOV
must use `SUM(Revenue) / SUM(Tix)`, rather than the unweighted mean of row AOVs.
Raw records remain unchanged. An explicit analysis-only view may exclude the
negative lead-time observation from timing distributions, while separately
reporting its row count, ticket count and revenue.

The historical booking window is finite. Early flight cohorts can lack bookings
made before the window starts; future flight cohorts lack bookings made after
the window ends. A recent flight cohort's observed curve must not be labelled
final demand. A fixed lookback window entirely covered by the data is a useful
descriptive sensitivity check, not proof of complete lifetime booking history.

Candidate solution families for later work are historical conditional booking
distributions with constrained allocation, and possibly more flexible learned
distributions if backtesting supports them. No optimiser, model, production job
or source-data cleaning is implemented as part of this review.
