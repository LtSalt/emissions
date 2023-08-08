<script>
	import '../app.css';
	import { scaleLinear, max, line, axisBottom, axisLeft, select, format } from 'd3';

	export let data;
	let { emissions } = data;

	let width = 0;
	let height = 0;
	let margins = { top: 20, right: 20, bottom: 40, left: 40 };
	$: innerWidth = width - margins.left - margins.right;
	$: innerHeight = height - margins.top - margins.bottom;

	$: xScale = scaleLinear([1990, 2022], [0, innerWidth]);
	$: yScale = scaleLinear([0, max(emissions.map((d) => d.total))], [innerHeight, 0]);

	$: d = line(
		(emissions) => xScale(emissions.year),
		(emissions) => yScale(emissions.total)
	)(emissions);

	let xAxis;
	let yAxis;

	$: if (width && height) {
		select(xAxis).call(axisBottom(xScale).tickFormat(format('')));
		select(yAxis).call(axisLeft(yScale));
	}
</script>

<div id="content" class="min-h-screen grid grid-rows-[auto_1fr] gap-4">
	<header class="flex justify-between px-6 py-4 bg-neutral-100">
		<div>Klimadashboard</div>
		<div>?</div>
	</header>
	<main
		class="mx-6 border-neutral-200 border-2 rounded-md mb-4 overflow-hidden grid gap-4 md:grid-cols-2 p-2"
	>
		<div class="aspect-square" bind:clientWidth={width} bind:clientHeight={height}>
			<svg width="100%" height="100%">
				<g style="transform: translate({margins.left}px, {margins.top}px);">
					<path {d} stroke="black" stroke-width="1" fill="none" />
					{#each emissions as d}
						<circle r="2" cx={xScale(d.year)} cy={yScale(d.total)} />
					{/each}
					<g bind:this={xAxis} style="transform: translate(0, {innerHeight}px);" />
					<g bind:this={yAxis} />
				</g>
			</svg>
		</div>
		<div class="aspect-square bg-slate-300" />
	</main>
</div>
