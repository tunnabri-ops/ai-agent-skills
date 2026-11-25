---
name: web-research
description: Use when the user asks for research, fact-checking, comparison, or current information from the web. It guides the agent to search broadly, open primary sources, cross-check claims against at least two independent sources, cite every factual claim with a URL, and distinguish live data from stale search-index copies.
---

# Web Research

Deep, verifiable web research. Every factual claim in the final answer must
trace back to a source the agent actually opened. Never invent a fact, a
number, a date, or a URL to fill a gap.

## When to Use This Skill

- The user asks "what is", "who is", "how much", "is it true that", or
  "compare X and Y".
- The answer depends on current information: prices, availability, status,
  schedules, versions, laws, or news.
- The user asks for sources, citations, or evidence.
- A claim needs checking before it is repeated to the user.

## When Not to Use It

- The answer is already in the conversation, a file the user supplied, or
  the agent's own verified working state.
- The user only wants an opinion, a draft, or creative writing with no
  factual claims.

## Workflow

### 1. Clarify the question

Restate the research question in one sentence. Split a broad question into
2-4 sub-questions. Note what would count as a good answer: a number, a date,
a yes/no, a comparison table, or a list of options.

Example: "Best free LLM hosting" becomes: (a) which providers offer a free
tier, (b) what are the limits, (c) what does setup require.

### 2. Search broadly

- Run at least 2 different search queries with different wording.
- Use the matching search vertical when one fits: news, finance, weather,
  sports, or datetime.
- Prefer queries that include a location or timeframe when the answer
  depends on either, for example "Cloudflare Workers AI free tier 2026".
- Collect 4-8 candidate sources before opening any of them.

### 3. Open primary sources first

- Open the official page, documentation, or announcement before blogs,
  aggregators, or forum posts.
- Read the page text. Note the published or updated date shown on the page
  itself, not the date the search result was crawled.
- If a page cannot be fetched, say so and use another source. A failed
  fetch never proves the claim is false or the option does not exist.

### 4. Cross-check every key claim

- Every load-bearing fact needs at least 2 independent sources.
- Two pages quoting the same press release are one source, not two.
- If sources disagree, report the disagreement and name both sides.
  Do not silently pick the one that fits the preferred answer.
- Numbers, dates, prices, and limits are load-bearing. Opinions and
  background context are not, but still cite them when they shape the answer.

### 5. Distinguish live data from stale data

- Search results are an index copy. They do not establish current price,
  stock, availability, booking options, or account state.
- For anything that changes (price, stock, status, schedule), verify
  against the live source: the provider's own page, API, or a live check.
- Adding today's date to a query does not verify the underlying state.
- Label each finding: "live-verified" (checked on the live source today),
  "source-dated" (page shows its own date), or "unverified" (only seen in
  search snippets).

### 6. Cite everything

- Put a URL next to each factual claim, not in a pile at the end.
- Copy URLs verbatim from search results or opened pages. Never guess,
  shorten, expand, or construct a URL from a domain name.
- If a source has no usable URL, name the source and say the link was
  unavailable.
- Quote at most 50 words from any single copyrighted work, and prefer a
  summary in the agent's own words.

## Output Format

Structure the answer as:

1. **Answer first** — the direct answer in 1-3 sentences.
2. **Evidence** — the key facts, each with its source URL and date.
3. **Conflicts and gaps** — where sources disagree or no source was found.
4. **What is still unverified** — anything the user should check live.

## Checklist

- [ ] Research question restated in one sentence.
- [ ] At least 2 different search queries run.
- [ ] Primary source opened before secondary sources.
- [ ] Each key fact confirmed by 2+ independent sources.
- [ ] Page dates read from the pages themselves.
- [ ] Live vs stale status labelled for every changing fact.
- [ ] Every factual claim carries a verbatim URL.
- [ ] Disagreements and gaps stated plainly, not hidden.

## Examples

### Good: price claim

> Cloudflare Workers AI free tier allows 10,000 neurons per day
> (https://developers.cloudflare.com/workers-ai/platform/limits/, page
> updated 2026). A second source, the Workers AI pricing page, lists the
> same limit.

### Bad: invented precision

> The service costs about $49 per month and supports 159,000 customers.
> (No source opened, no URL, "about" hides the missing evidence.)

### Good: handling disagreement

> Source A says the free tier is 10,000 neurons/day; Source B, a 2025 blog
> post, says 5,000. The official docs (2026) say 10,000, so that figure is
> used and the older post is noted as outdated.

## Pitfalls

- **Trusting the snippet.** A search snippet is not a source. Open the page.
- **Single-source facts.** One blog post is a lead, not a finding.
- **Guessed URLs.** A plausible-looking URL that was never returned by a
  tool is not a citation; it is an invention.
- **Stale index as live truth.** A result crawled last week does not prove
  today's price or availability.
- **Cherry-picking.** Reporting only the sources that agree with the
  expected answer is misinformation, even if each quote is accurate.
- **Over-quoting.** Long copied passages violate the 50-word limit and add
  nothing a summary would not say better.
