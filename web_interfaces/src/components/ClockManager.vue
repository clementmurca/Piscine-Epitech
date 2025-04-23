<template>
  <div class="bg-gray-100 min-h-screen p-8">
    <h2 class="text-4xl font-bold mb-6 text-gray-800 bg-gradient-to-r from-blue-500 to-indigo-600 text-transparent bg-clip-text">
      CLOCK MANAGER
    </h2>

    <div class="bg-[#342ee5] shadow-lg rounded-lg p-6 flex items-center justify-between h-44">
      <div class="flex flex-col">
        <div class="text-white mb-4">
          <p v-if="userId" class="mb-2 font-bold">User ID: {{ userId }}</p>
          <p v-else class="mb-2 text-red-500">No user ID provided</p>
          <p class="mb-2 font-bold text-white">Current Status: 
            <span :class="clockIn ? 'text-green-600' : 'text-red-600'">{{ clockIn ? 'Working' : 'Not Working' }}</span>
          </p>
          <p v-if="startDateTime" class="mb-2 font-bold text-white">Start Time: {{ formatDate(startDateTime) }}</p>
        </div>
        <div class="flex items-center">
          <p class="mr-4 text-white font-bold">Clock In/Out:</p>
          <button 
            @click="clock" 
            :class="clockIn ? 'bg-red-500 hover:bg-red-600' : 'bg-green-500 hover:bg-green-600'"
            class="text-white font-bold py-2 px-6 rounded transition duration-300 ease-in-out" 
            :disabled="!userId"
          >
            {{ clockIn ? 'Clock Out' : 'Clock In' }}
          </button>
        </div>
      </div>
      <img src="../image/clock_in.png" alt="Clock In" class="w-24 h-24 md:w-44 md:h-44" />
    </div>
    <br>
    <br>
    <!-- Boutons et champs de filtre -->
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

    <!-- Sélecteurs de date -->
    <div v-if="showDateSelectors" class="flex mb-4">
      <input
        v-model="filter.start_date"
        type="date"
        class="shadow border rounded w-44 py-2 px-4 mr-2 text-gray-700 focus:outline-none"
      />
      <input
        v-model="filter.end_date"
        type="date"
        class="shadow border rounded w-44 py-2 px-4 text-gray-700 focus:outline-none"
      />
      <button
        @click="applyFilters"
        class="bg-gradient-to-r from-blue-500 to-indigo-600 text-white px-4 py-2 rounded shadow hover:from-blue-600 hover:to-indigo-700 transition"
      >
        Apply
      </button>
    </div>

    <!-- Tableau des horaires de travail -->
    <div class="shadow-lg rounded-lg bg-white overflow-x-auto">
      <table class="min-w-full bg-white rounded-lg">
        <thead>
          <tr class="bg-blue-50 text-gray-600 text-sm uppercase leading-normal">
            <th class="py-3 px-4 text-left">Start</th>
            <th class="py-3 px-4 text-left">End</th>
            <th class="py-3 px-4 text-center">Hours Worked</th>
          </tr>
        </thead>
        <tbody class="text-gray-700 text-sm">
          <tr v-for="(wt, index) in filteredWork" :key="index" class="border-b border-gray-200 hover:bg-gray-100">
            <td class="py-3 px-4">{{ formatDate(wt.start.time) }}</td>
            <td class="py-3 px-4">{{ formatDate(wt.end.time) }}</td>
            <td class="py-3 px-4 text-center">{{ calculateHoursWorked(wt.start.time, wt.end.time) }} hours</td>
          </tr>
          <tr v-if="filteredWork.length === 0">
            <td colspan="3" class="py-3 px-6 text-center text-gray-500">No records found</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';
import { formatDate } from '../../utils/FormatDate'; 
import { FilterIcon, XCircleIcon as ResetIcon } from '@heroicons/vue/outline';


const API_URL = process.env.TIME_MANAGER_APP_URL || 'http://localhost:4000/api';
const user = JSON.parse(localStorage.getItem('user'));
const userId = ref(user.id);

const showDateSelectors = ref(false);
const clockIn = ref(false);
const startDateTime = ref(null);
const work = ref([]);
const filteredWork = ref([]);
const filter = ref({
  start_date: '',
  end_date: ''
});



const toggleDateSelectors = () => {
  showDateSelectors.value = !showDateSelectors.value;
};

const fetchCurrentClock = async () => {
  if (!userId.value) { 
    console.error('No user ID provided');
    return;
  }
  
  try {
    const response = await axios.get(`${API_URL}/clocks/${userId.value}`);
    const clocks = response.data.data;
    const lastClock = clocks[clocks.length - 1];
    
    if (lastClock && lastClock.status) {
      clockIn.value = true;
      startDateTime.value = new Date(lastClock.time);
    } else {
      clockIn.value = false;
      startDateTime.value = null;
    }
  } catch (error) {
    console.error('Error fetching clock:', error);
  }
};


const clock = async () => {
  if (!userId.value) { 
    console.error('No user ID provided');
    return;
  }

  try {
    const now = new Date().toISOString();
    const response = await axios.post(`${API_URL}/clocks/${userId.value}`, {
      clock: {
        time: now,
        status: !clockIn.value
      }
    });
    
    if (response.data.data) {
      clockIn.value = !clockIn.value;
      startDateTime.value = clockIn.value ? new Date(now) : null;
    }
  } catch (error) {
    console.error('Error updating clock:', error);
  }
};


const fetchWorkingTimes = async () => {
  try {
    const response = await axios.get(`${API_URL}/clocks/${userId.value}`);
    work.value = Array.isArray(response.data.data) ? response.data.data : [];
    applyFilters();
  } catch (error) {
    console.error('Error fetching working times:', error);
  }
};

// Group working times by clock in/out pairs
const groupedWork = computed(() => {
  const grouped = [];

  work.value.forEach(clock => {
    const clockEntry = { time: clock.time, status: clock.status };
    if (clock.status) {
      grouped.push({ start: clockEntry });
    } else {
      const lastEntry = grouped[grouped.length - 1];
      if (lastEntry && !lastEntry.end) {
        lastEntry.end = clockEntry;
      }
    }
  });

  return grouped.filter(item => item.start && item.end);
});

// Apply filters to working times
const applyFilters = () => {
  filteredWork.value = groupedWork.value.filter(wt => {
    const workStartDate = formatDate(wt.start.time).split(' ')[0];
    const workEndDate = formatDate(wt.end.time).split(' ')[0];

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
  filteredWork.value = groupedWork.value; 
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




onMounted(async () => {
  await fetchCurrentClock();
  await fetchWorkingTimes();
});
</script>

<style scoped>
.clock-manager {
  max-width: 400px;
  margin: 20px auto;
}

table {
  width: 100%;
}

button[disabled] {
  cursor: not-allowed;
  opacity: 0.5;
}
</style>

