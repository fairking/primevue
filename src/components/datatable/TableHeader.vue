<template>
    <thead class="p-datatable-thead">
        <template v-if="!columnGroup">
            <tr>
                <template v-for="(col,i) of columns">
                    <th v-if="rowGroupMode !== 'subheader' || (groupRowsBy !== columnProp(col, 'field'))" :tabindex="columnProp(col, 'sortable') ? '0' : null" @keydown="onColumnKeyDown($event, col)"
                        :key="columnProp(col, 'columnKey')||columnProp(col, 'field')||i" :style="columnProp(col, 'headerStyle')" :class="getColumnHeaderClass(col)"
                        @click="onColumnHeaderClick($event, col)" @mousedown="onColumnHeaderMouseDown($event, col)"
                        @dragstart="onColumnHeaderDragStart($event)" @dragover="onColumnHeaderDragOver($event)" @dragleave="onColumnHeaderDragLeave($event)" @drop="onColumnHeaderDrop($event)"
                        :colspan="columnProp(col, 'colspan')" :rowspan="columnProp(col, 'rowspan')" :aria-sort="getAriaSort(col)">
                        <span class="p-column-resizer" @mousedown="onColumnResizeStart($event)" v-if="resizableColumns"></span>
                        <div class="p-column-header-content">
                            <component :is="col.children.header" :column="col" v-if="col.children && col.children.header"/>
                            <span class="p-column-title" v-if="columnProp(col, 'header')">{{columnProp(col, 'header')}}</span>
                            <span v-if="columnProp(col, 'sortable')" :class="getSortableColumnIcon(col)"></span>
                            <span v-if="isMultiSorted(col)" class="p-sortable-column-badge">{{getMultiSortMetaIndex(col) + 1}}</span>
                            <DTHeaderCheckbox :checked="allRowsSelected" @change="onHeaderCheckboxChange($event)" :disabled="empty" v-if="columnProp(col, 'selectionMode') ==='multiple' && filterDisplay !== 'row'" />
                            <DTColumnFilter v-if="filterDisplay === 'menu' && col.children && col.children.filter" :field="columnProp(col, 'filterField')||columnProp(col, 'field')" :type="columnProp(col, 'dataType')" display="menu"  
                            :showMenu="columnProp(col, 'showFilterMenu')" :filterElement="col.children && col.children.filter" 
                            :filterHeaderTemplate="col.children && col.children.filterheader" :filterFooterTemplate="col.children && col.children.filterfooter" 
                            :filterClearTemplate="col.children && col.children.filterclear" :filterApplyTemplate="col.children && col.children.filterapply" 
                            :filters="filters" :filtersStore="filtersStore" @filter-change="$emit('filter-change', $event)" @filter-apply="$emit('filter-apply')" :filterMenuStyle="columnProp(col, 'filterMenuStyle')" :filterMenuClass="columnProp(col, 'filterMenuClass')"
                            :showOperator="columnProp(col, 'showFilterOperator')" :showClearButton="columnProp(col, 'showClearButton')" :showApplyButton="columnProp(col, 'showApplyButton')"
                            :showMatchModes="columnProp(col, 'showFilterMatchModes')" :showAddButton="columnProp(col, 'showAddButton')" :matchModeOptions="columnProp(col, 'filterMatchModeOptions')" :maxConstraints="columnProp(col, 'maxConstraints')"
                            @operator-change="$emit('operator-change',$event)" @matchmode-change="$emit('matchmode-change', $event)" @constraint-add="$emit('constraint-add', $event)" @constraint-remove="$emit('constraint-remove', $event)" @apply-click="$emit('apply-click',$event)"/>
                        </div>
                    </th>
                </template>
            </tr>
            <tr v-if="filterDisplay === 'row'">
                <template v-for="(col,i) of columns">
                    <th v-if="rowGroupMode !== 'subheader' || (groupRowsBy !== columnProp(col, 'field'))" :key="columnProp(col, 'columnKey')||columnProp(col, 'field')||i"
                        :class="getFilterColumnHeaderClass(col)" :style="columnProp(col, 'filterHeaderStyle')">
                        <DTColumnFilter v-if="col.children && col.children.filter" :field="columnProp(col, 'filterField')||columnProp(col, 'field')" :type="columnProp(col, 'dataType')" display="row"  
                        :showMenu="columnProp(col, 'showFilterMenu')" :filterElement="col.children && col.children.filter" :filterHeader="col.children && col.children.filterHeader" :filterFooter="col.children && col.children.filterFooter" 
                        :filters="filters" :filtersStore="filtersStore" @filter-change="$emit('filter-change', $event)" @filter-apply="$emit('filter-apply')" :filterMenuStyle="columnProp(col, 'filterMenuStyle')" :filterMenuClass="columnProp(col, 'filterMenuClass')"
                        :showOperator="columnProp(col, 'showFilterOperator')" :showClearButton="columnProp(col, 'showClearButton')" :showApplyButton="columnProp(col, 'showApplyButton')"
                        :showMatchModes="columnProp(col, 'showFilterMatchModes')" :showAddButton="columnProp(col, 'showAddButton')" :matchModeOptions="columnProp(col, 'filterMatchModeOptions')" :maxConstraints="columnProp(col, 'maxConstraints')" 
                        @operator-change="$emit('operator-change',$event)" @matchmode-change="$emit('matchmode-change', $event)" @constraint-add="$emit('constraint-add', $event)" @constraint-remove="$emit('constraint-remove', $event)" @apply-click="$emit('apply-click',$event)"/>
                        <DTHeaderCheckbox :checked="allRowsSelected" @change="onHeaderCheckboxChange($event)" :disabled="empty" v-if="columnProp(col, 'selectionMode')==='multiple'" />
                    </th>
                </template>
            </tr>
        </template>
        <template v-else>
            <tr v-for="(row,i) of columnGroup.children.default()" :key="i">
                <th v-for="(col,i) of row.children.default()" :key="columnProp(col, 'columnKey')||columnProp(col, 'field')||i" :style="columnProp(col, 'headerStyle')" :class="getColumnHeaderClass(col)" :tabindex="columnProp(col, 'sortable') ? '0' : null"
                    @click="onColumnHeaderClick($event, col)" @keydown="onColumnKeyDown($event, col)" @dragstart="onColumnHeaderDragStart($event)" @dragover="onColumnHeaderDragOver($event)" @dragleave="onColumnHeaderDragLeave($event)" @drop="onColumnHeaderDrop($event)"
                    :colspan="columnProp(col, 'colspan')" :rowspan="columnProp(col, 'rowspan')" :aria-sort="getAriaSort(col)">
                    <component :is="col.children.header" :column="col" v-if="col.children && col.children.header"/>
                    <span class="p-column-title" v-if="columnProp(col, 'header')">{{columnProp(col, 'header')}}</span>
                    <span v-if="columnProp(col, 'sortable')" :class="getSortableColumnIcon(col)"></span>
                    <span v-if="isMultiSorted(col)" class="p-sortable-column-badge">{{getMultiSortMetaIndex(col) + 1}}</span>
                    <component :is="col.children.filter" :column="col" v-if="col.children && col.children.filter"/>
                    <DTHeaderCheckbox :checked="allRowsSelected" @change="onHeaderCheckboxChange($event)" :disabled="empty" v-if="columnProp(col, 'selectionMode') ==='multiple'" />
                </th>
            </tr>
        </template>
    </thead>
</template>

<script>
import {DomHandler} from 'primevue/utils';
import HeaderCheckbox from './HeaderCheckbox.vue';
import ColumnFilter from './ColumnFilter';

export default {
    emits: ['column-click', 'column-mousedown', 'column-dragstart', 'column-dragover', 'column-dragleave', 'column-drop',
            'column-resizestart', 'checkbox-change', 'column-click','filter-change', 'filter-apply', 
            'operator-change', 'matchmode-change', 'constraint-add', 'constraint-remove', 'filter-clear', 'apply-click'],
    props: {
		columnGroup: {
            type: null,
            default: null
        },
        columns: {
            type: null,
            default: null
        },
        rowGroupMode: {
            type: String,
            default: null
        },
        groupRowsBy: {
            type: [Array,String],
            default: null
        },
        resizableColumns: {
            type: Boolean,
            default: false
        },
        allRowsSelected: {
            type: Boolean,
            default: false
        },
        empty: {
            type: Boolean,
            default: false
        },
        sortMode: {
            type: String,
            default: 'single'
        },
        sortField: {
            type: [String, Function],
            default: null
        },
        sortOrder: {
            type: Number,
            default: null
        },
        multiSortMeta: {
            type: Array,
            default: null
        },
        filters: {
            type: Object,
            default: null
        },
        filtersStore: {
            type: Object,
            default: null
        },
        filterDisplay: {
            type: String,
            default: null
        }
    },
    methods: {
        columnProp(col, prop) {
            return col.props ? ((col.type.props[prop].type === Boolean && col.props[prop] === '') ? true : col.props[prop]) : null;
        },
        isMultiSorted(column) {
            return this.columnProp(column, 'sortable') && this.getMultiSortMetaIndex(column) > -1
        },
        isColumnSorted(column) {
            return this.sortMode === 'single' ? (this.sortField && (this.sortField === this.columnProp(column, 'field') || this.sortField === this.columnProp(column, 'sortField'))) : this.isMultiSorted(column);
        },
        getColumnHeaderClass(column) {
            return [this.columnProp(column, 'headerClass'),
                    {'p-sortable-column': this.columnProp(column, 'sortable')},
                    {'p-resizable-column': this.resizableColumns},
                    {'p-highlight': this.isColumnSorted(column)}
            ];
        },
        getFilterColumnHeaderClass(column) {
            return ['p-filter-column', this.columnProp(column, 'filterHeaderClass')];
        },
        getSortableColumnIcon(column) {
            let sorted = false;
            let sortOrder = null;

            if (this.sortMode === 'single') {
                sorted = this.sortField && (this.sortField === this.columnProp(column, 'field') || this.sortField === this.columnProp(column, 'sortField'));
                sortOrder = sorted ? this.sortOrder: 0;
            }
            else if (this.sortMode === 'multiple') {
                let metaIndex = this.getMultiSortMetaIndex(column);
                if (metaIndex > -1) {
                    sorted = true;
                    sortOrder = this.multiSortMeta[metaIndex].order;
                }
            }

            return [
                'p-sortable-column-icon pi pi-fw', {
                    'pi-sort-alt': !sorted,
                    'pi-sort-amount-up-alt': sorted && sortOrder > 0,
                    'pi-sort-amount-down': sorted && sortOrder < 0
                }
            ];
        },
        getMultiSortMetaIndex(column) {
            let index = -1;

            for (let i = 0; i < this.multiSortMeta.length; i++) {
                let meta = this.multiSortMeta[i];
                if (meta.field === this.columnProp(column, 'field') || meta.field === this.columnProp(column, 'sortField')) {
                    index = i;
                    break;
                }
            }

            return index;
        },
        onColumnHeaderClick(event, col) {
            this.$emit('column-click', {originalEvent: event, column: col});
        },
        onColumnHeaderMouseDown(event, col) {
            this.$emit('column-mousedown', {originalEvent: event, column: col});
        },
        onColumnHeaderDragStart(event) {
            this.$emit('column-dragstart', event);
        },
        onColumnHeaderDragOver(event) {
            this.$emit('column-dragover', event);
        },
        onColumnHeaderDragLeave(event) {
            this.$emit('column-dragleave', event);
        },
        onColumnHeaderDrop(event) {
            this.$emit('column-drop', event);
        },
        onColumnResizeStart(event) {
            this.$emit('column-resizestart', event);
        },
        onHeaderCheckboxChange(event) {
            this.$emit('checkbox-change', event);
        },
        onColumnKeyDown(event, col) {
            if (event.which === 13 && event.currentTarget.nodeName === 'TH' && DomHandler.hasClass(event.currentTarget, 'p-sortable-column')) {
                this.$emit('column-click', {originalEvent: event, column: col});
            }
        },
        getAriaSort(column) {
            if (this.columnProp(column, 'sortable')) {
                const sortIcon = this.getSortableColumnIcon(column);
                if (sortIcon[1]['pi-sort-amount-down'])
                    return 'descending';
                else if (sortIcon[1]['pi-sort-amount-up-alt'])
                    return 'ascending';
                else
                    return 'none';
            }
            else {
                return null;
            }
        }
    },
    components: {
        'DTHeaderCheckbox': HeaderCheckbox,
        'DTColumnFilter': ColumnFilter
    }
}
</script>
