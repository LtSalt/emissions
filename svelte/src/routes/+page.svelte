<script>
	import '../app.css';
	import {
		scaleLinear,
		max,
		axisBottom,
		axisLeft,
		select,
		format,
		stack,
		area,
		scaleOrdinal,
		pie,
		arc
	} from 'd3';

	// import data
	export let data;
	let { emissions } = data;

	// create stacks
	const sectors = ['energy', 'transport', 'buildings', 'industry', 'agriculture', 'waste'];
	const series = stack().keys(sectors)(emissions);

	// define dimensions
	let width = 0;
	let height = 0;
	let margins = { top: 20, right: 20, bottom: 40, left: 40 };
	$: innerWidth = width - margins.left - margins.right;
	$: innerHeight = height - margins.top - margins.bottom;

	// define scales
	$: scaleX = scaleLinear([1990, 2022], [0, innerWidth]);
	$: scaleY = scaleLinear([0, max(emissions.map((d) => d.total))], [innerHeight, 0]);

	const colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#ffff33'];
	const scaleColor = scaleOrdinal(sectors, colors);

	// define and draw axes
	let xAxis;
	let yAxis;

	$: if (width && height) {
		select(xAxis).call(axisBottom(scaleX).tickFormat(format('')));
		select(yAxis).call(axisLeft(scaleY));
	}

	// draw areas
	$: areaGenerator = area() // reactive declarations (as the axes) are initilized at last
		.x((d) => scaleX(d.data.year))
		.y0((d) => scaleY(d[0]))
		.y1((d) => scaleY(d[1]));

	$: stacks = series.map((sector) => areaGenerator(sector));

	// donut
	$: radius = Math.min(innerWidth, innerHeight) / 2;
	const angleGenerator = pie().value((d) => d[1]);
	let selectedYear = 2022;
	$: ({ year, ...selection } = emissions.find((d) => d.year === selectedYear));
	$: angles = angleGenerator(Object.entries(selection));
	$: donutGenerator = arc()
		.innerRadius(radius / 2)
		.outerRadius(radius);
	$: slices = angles.map((angle) => donutGenerator(angle));
	$: console.log(angles);
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
						<path d={stacks[i]} stroke="black" stroke-width="1" fill={scaleColor(s.key)} />
					{/each}
					<g bind:this={xAxis} style="transform: translate(0, {innerHeight}px);" />
					<g bind:this={yAxis} />
				</g>
			</svg>
		</div>
		<div class="aspect-square" bind:clientWidth={width} bind:clientHeight={height}>
			<svg width="100%" height="100%">
				<g style="transform: translate({width / 2}px, {height / 2}.px);">
					{#each slices as slice, i}
						<path d={slice} fill={scaleColor(angles[i].data[0])} />
					{/each}
				</g>
			</svg>
		</div>
	</main>
</div>
