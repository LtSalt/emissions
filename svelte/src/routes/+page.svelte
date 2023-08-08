<script>
	import '../app.css';
	import {
		scaleLinear,
		max,
		line,
		axisBottom,
		axisLeft,
		select,
		format,
		stack,
		area,
		scaleOrdinal
	} from 'd3';

	// import data
	export let data;
	let { emissions } = data;

	// define dimensions
	let width = 0;
	let height = 0;
	let margins = { top: 20, right: 20, bottom: 40, left: 40 };
	$: innerWidth = width - margins.left - margins.right;
	$: innerHeight = height - margins.top - margins.bottom;

	// define scales
	$: xScale = scaleLinear([1990, 2022], [0, innerWidth]);
	$: yScale = scaleLinear([0, max(emissions.map((d) => d.total))], [innerHeight, 0]);

	// define and draw axes
	let xAxis;
	let yAxis;

	$: if (width && height) {
		select(xAxis).call(axisBottom(xScale).tickFormat(format('')));
		select(yAxis).call(axisLeft(yScale));
	}

	// create stacks & draw areas
	const sectors = ['energy', 'transport', 'buildings', 'industry', 'agriculture', 'waste'];
	const series = stack().keys(sectors)(emissions);

	$: areaGenerator = area() // reactive declarations (as the axes) are initilized at last
		.x((d) => xScale(d.data.year))
		.y0((d) => yScale(d[0]))
		.y1((d) => yScale(d[1]));

	$: stacks = series.map((sector) => areaGenerator(sector));

	// color scale
	const colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#ffff33'];
	const colorScale = scaleOrdinal(sectors, colors);
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
					{#each series as s, i}
						<path d={stacks[i]} stroke="black" stroke-width="1" fill={colorScale(s.key)} />
					{/each}
					<g bind:this={xAxis} style="transform: translate(0, {innerHeight}px);" />
					<g bind:this={yAxis} />
				</g>
			</svg>
		</div>
		<div class="aspect-square bg-slate-300" />
	</main>
</div>
