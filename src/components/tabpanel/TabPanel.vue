<template>
    <div class="p-tabview-panel" role="tabpanel" v-show="isTabActive()">
        <slot></slot>
    </div>
</template>

<script>
export default {
    name: 'tabpanel',
    props: {
        header: null,
        active: Boolean,
        disabled: Boolean
    },
    data() {
        return {
            index: null
        }
    },
    created() {
        this.$parent.$children.forEach((child, i) => {
            if (child === this) this.index = i
        })
    },
    mounted() {
        if (this.active)
			this.$parent.d_activeIndex = this.index;
	},
    methods: {
        isTabActive() {
            let activeArray = this.$parent.d_activeIndex;
            var active = this.$parent.multiple ? activeArray && activeArray.includes(this.index) : this.index === activeArray;
			this.$emit('update:active', active);
			return active;
        }
    }
}
</script>
