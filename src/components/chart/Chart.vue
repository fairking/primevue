<template>
    <div class="p-chart">
        <canvas ref="canvas" :width="width" :height="height" @click="onCanvasClick($event)"></canvas>
    </div>
</template>

<script>
// import * as Chart from 'chart.js/auto';

export default {
    props: {
        type: String,
        data: null,
        options: null,
        plugins: null,
        width: Number,
        height: Number
    },
    chart: null,
    mounted() {
        this.initChart();
    },
    beforeDestroy() {
        if (this.chart) {
            this.chart.destroy();
            this.chart = null;
        }
    },
    methods: {
        initChart() {

            if (this.height)
                this.$refs.canvas.height = this.height;
                
            if (this.width)
				this.$refs.canvas.width = this.width;
                
            import('chart.js/auto').then((module) => {
                if (module && module.default) {
                    this.chart = new module.default(this.$refs.canvas, {
                        type: this.type,
                        data: this.data,
                        options: this.options,
                        plugins: this.plugins
                    });
                }
            });
        },
        getCanvas() {
            return this.$canvas;
        },
        getBase64Image() {
            return this.chart.toBase64Image();
        },
        refresh() {
            if (this.chart) {
                this.chart.update();
            }
        },
        reinit() {
            if (this.chart) {
                this.chart.destroy();
                this.initChart();
            }
        },
        onCanvasClick(event) {
            if (this.chart) {
                const element = this.chart.getElementsAtEventForMode(event, 'nearest', { intersect: true }, false);
                const dataset = this.chart.getElementsAtEventForMode(event, 'dataset', { intersect: true }, false);

                if (element && element[0] && dataset) {
                    this.$emit('select', {originalEvent: event, element: element[0], dataset: dataset});
                } else {
                    this.$emit('click', event);
                }
            }
        },
        generateLegend() {
            if (this.chart) {
                return this.chart.generateLegend();
            }
        }
    }
}
</script>

<style>
.p-chart {
    position: relative;
}
</style>