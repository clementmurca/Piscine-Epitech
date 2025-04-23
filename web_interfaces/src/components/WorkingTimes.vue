<template>
  <div class="p-4 bg-gray-100 min-h-screen">
    <h2 class="text-4xl font-bold mb-6 text-gray-800 bg-gradient-to-r from-blue-500 to-indigo-600 text-transparent bg-clip-text">
      Working Times
    </h2>

    <div class="mb-6 flex items-center">
      <button @click="toggleDateSelectors" class="text-gray-600 hover:text-blue-500 focus:outline-none">
        <FilterIcon name="filter" class="h-6 w-6" />
      </button>
      <span class="ml-2 text-xl font-semibold text-gray-700">Filter Working Times</span>
      <button @click="resetFilters" class="ml-4 text-gray-600 hover:text-blue-500 focus:outline-none">
        <ResetIcon name="x-circle" class="h-6 w-6" /> 
      </button>
      <span class="ml-2 text-sm font-semibold text-gray-700">Reset Filters</span>
    </div>
    <div v-if="showDateSelectors" class="flex mb-4">
      <div class="mr-2">
        <input
          v-model="filter.start_date"
          type="date"
          class="shadow appearance-none border rounded w-44 py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
        />
      </div>
      <div class="mr-2">
        <input
          v-model="filter.end_date"
          type="date"
          class="shadow appearance-none border rounded w-44 py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
        />
      </div>
      <button
        @click="applyFilters"
        class="bg-gradient-to-r from-blue-500 to-indigo-600 text-white px-4 py-2 rounded shadow hover:from-blue-600 hover:to-indigo-700 transition"
      >
        Apply
      </button>
    </div>
    <div class="overflow-x-auto shadow-lg rounded-lg bg-white">
      <table class="min-w-full bg-white rounded-lg">
        <thead>
          <tr class="bg-blue-50 text-gray-600 text-sm uppercase leading-normal">
            <th class="py-2 px-4 text-left">Start</th>
            <th class="py-2 px-4 text-left">End</th>
            <th class="py-2 px-4 text-center">Hours Worked</th>
          </tr>
        </thead>
        <tbody class="text-gray-700 text-sm">
          <tr v-for="wt in filteredWork" :key="wt.id" class="border-b border-gray-200 hover:bg-gray-100">
            <td class="py-2 px-4 text-left">{{ formatDate(wt.start) }}</td>
            <td class="py-2 px-4 text-left">{{ formatDate(wt.end) }}</td>
            <td class="py-2 px-4 text-center">{{ calculateHoursWorked(wt.start, wt.end) }} hours</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { formatDate } from '../../utils/FormatDate';
import { FilterIcon, XCircleIcon as ResetIcon } from '@heroicons/vue/outline'; 

const API_URL = process.env.TIME_MANAGER_APP_URL || 'http://localhost:4000/api';
const userId = JSON.parse(localStorage.getItem('user')).id;

const work = ref([]);
const filter = ref({
  start_date: '',
  end_date: ''
});
const showDateSelectors = ref(false); 

const fetchWorkingTimes = async () => {
  try {
    const response = await axios.get(`${API_URL}/workingtimes/${userId}`);
    work.value = Array.isArray(response.data.data) ? response.data.data : [];
  } catch (error) {
    console.error('Error fetching working times:', error);
  }
};

const filteredWork = ref([]);

const toggleDateSelectors = () => {
  showDateSelectors.value = !showDateSelectors.value; 
};

const applyFilters = () => {
  filteredWork.value = work.value.filter(wt => {
    const workStartDate = formatDate(wt.start).split(' ')[0];
    const workEndDate = formatDate(wt.end).split(' ')[0];

    const start = filter.value.start_date || null;
    const end = filter.value.end_date || null;

    const isAfterStartDate = !start || workStartDate >= start;
    const isBeforeEndDate = !end || workEndDate <= end;

    return isAfterStartDate && isBeforeEndDate;
  });
};

const resetFilters = () => {
  filter.value.start_date = '';
  filter.value.end_date = '';
  filteredWork.value = work.value; 
};

const calculateHoursWorked = (start, end) => {
  const formattedStart = formatDate(start);
  const formattedEnd = formatDate(end);

  const startTime = new Date(formattedStart);
  const endTime = new Date(formattedEnd);

  const diffInMilliseconds = endTime - startTime;
  const diffInHours = diffInMilliseconds / (1000 * 60 * 60);

  return diffInHours.toFixed(0);
};

onMounted(() => {
  fetchWorkingTimes().then(() => {
    filteredWork.value = work.value; 
  });
});
</script>
