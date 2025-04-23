<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <h1 class="text-3xl font-bold text-center text-blue-600 mb-8">Time Management Dashboard</h1>

    <!-- User Registration Chart -->
    <div class="mb-8 bg-white p-6 rounded-lg shadow">
      <h2 class="text-2xl font-semibold text-gray-700 mb-4">User Registrations</h2>
      <div class="chart-container">
        <Line
          v-if="registrationData.datasets && registrationData.datasets.length > 0"
          :data="registrationData"
          :options="chartOptions"
        />
        <div v-else class="flex items-center justify-center h-full">
          <p class="text-gray-500">Loading registration data...</p>
        </div>
      </div>
    </div>

    <!-- Clock Events Chart -->
    <div class="mb-8 bg-white p-6 rounded-lg shadow">
      <h2 class="text-2xl font-semibold text-gray-700 mb-4">Clock Events</h2>
      <div class="chart-container">
        <Bar
          v-if="clockEventsData.datasets && clockEventsData.datasets.length > 0"
          :data="clockEventsData"
          :options="chartOptions"
        />
        <div v-else class="flex items-center justify-center h-full">
          <p class="text-gray-500">Loading clock events data...</p>
        </div>
      </div>
    </div>

    <!-- Working Time Chart -->
    <div class="mb-8 bg-white p-6 rounded-lg shadow">
      <h2 class="text-2xl font-semibold text-gray-700 mb-4">Working Hours</h2>
      <div class="chart-container">
        <Line
          v-if="workingTimeData.datasets && workingTimeData.datasets.length > 0"
          :data="workingTimeData"
          :options="workingTimeChartOptions"
        />
        <div v-else class="flex items-center justify-center h-full">
          <p class="text-gray-500">Loading working hours data...</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { Line, Bar } from 'vue-chartjs';

import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  LinearScale,
  PointElement,
  CategoryScale,
  BarElement
} from 'chart.js';
import axios from 'axios';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const API_URL = process.env.TIME_MANAGER_APP_URL || 'http://localhost:4000/api';
const userId = JSON.parse(localStorage.getItem('user'))?.id;

const registrationData = ref({ labels: [], datasets: [] });
const clockEventsData = ref({ labels: [], datasets: [] });
const workingTimeData = ref({ labels: [], datasets: [] });

const chartOptions = ref({
  responsive: true,
  maintainAspectRatio: true,
  aspectRatio: 2,
  scales: {
    y: {
      beginAtZero: true,
      grid: {
        drawBorder: false
      }
    },
    setup() {
      const registrationData = ref({ labels: [], datasets: [] });
      const totalHoursData = ref({ labels: [], datasets: [] });
      const clockEventsData = ref({ labels: [], datasets: [] });
      const individualHoursData = ref({ labels: [], datasets: [] });
      const clockInOutData = ref({ labels: [], datasets: [] });
      const timeAllocationData = ref({ labels: [], datasets: [] });
  
      const chartOptions = ref({
        responsive: true,
        maintainAspectRatio: true,  
        aspectRatio: 2,  
        scales: {
          x: {
            ticks: { maxRotation: 45, minRotation: 45 }
          },
          y: {
            beginAtZero: true
          }
        }
      });
  
      const fetchGeneralGraphsData = async () => {
        try {
          const [usersResponse, workResponse, clocksResponse] = await Promise.all([
            axios.get(`${API_URL}/users`),
            axios.get(`${API_URL}/workingtime`),
            axios.get(`${API_URL}/clocks`)
          ]);
  
          if (Array.isArray(usersResponse.data.data)) {
            const registrationByDay = processRegistrationData(usersResponse.data.data);
            registrationData.value = {
              labels: registrationByDay.labels,
              datasets: [{
                label: 'New Users',
                data: registrationByDay.data,
                fill: false,
                borderColor: 'rgba(75, 192, 192, 1)',
                tension: 0.1
              }]
            };
          }
  
          if (Array.isArray(workResponse.data.data)) {
            const totalHoursByDay = processWorkHoursData(workResponse.data.data);
            totalHoursData.value = {
              labels: totalHoursByDay.labels,
              datasets: [{
                label: 'Total Hours Worked',
                data: totalHoursByDay.data,
                backgroundColor: 'rgba(54, 162, 235, 0.2)',
                borderColor: 'rgba(54, 162, 235, 1)',
                borderWidth: 1
              }]
            };
          }
  
          if (Array.isArray(clocksResponse.data.data)) {
            const clockEvents = processClockEventsData(clocksResponse.data.data);
            clockEventsData.value = {
              labels: ['Clock-ins', 'Clock-outs'],
              datasets: [{
                label: 'Clock Events',
                data: clockEvents,
                backgroundColor: ['rgba(255, 99, 132, 0.2)', 'rgba(255, 206, 86, 0.2)'],
                borderColor: ['rgba(255, 99, 132, 1)', 'rgba(255, 206, 86, 1)'],
                borderWidth: 1
              }]
            };
          }
        } catch (error) {
          console.error("Error fetching general graphs data", error);
        }
      };
  
      const fetchUserSpecificData = async () => {
        try {
          const [userWorkResponse, userClockResponse] = await Promise.all([
            axios.get(`${API_URL}/workingtime/1`),
            axios.get(`${API_URL}/clocks/1`)
          ]);
  
          if (Array.isArray(userWorkResponse.data.data)) {
            const individualWorkData = processIndividualWorkHours(userWorkResponse.data.data);
            individualHoursData.value = {
              labels: individualWorkData.labels,
              datasets: [{
                label: 'Hours Worked',
                data: individualWorkData.data,
                backgroundColor: 'rgba(153, 102, 255, 0.2)',
                borderColor: 'rgba(153, 102, 255, 1)',
                borderWidth: 1
              }]
            };
          }
  
          if (Array.isArray(userClockResponse.data.data)) {
            const clockInOut = processClockInOutData(userClockResponse.data.data);
            clockInOutData.value = {
              labels: clockInOut.labels,
              datasets: [{
                label: 'Clock-in/Clock-out Times',
                data: clockInOut.data,
                fill: false,
                borderColor: 'rgba(75, 192, 192, 1)',
                tension: 0.1
              }]
            };
          }
  
          const timeAllocation = processTimeAllocationData(individualHoursData.value);
          timeAllocationData.value = {
            labels: timeAllocation.labels,
            datasets: [{
              label: 'Time Allocation',
              data: timeAllocation.data,
              backgroundColor: [
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(255, 206, 86, 0.2)',
                'rgba(75, 192, 192, 0.2)',
                'rgba(153, 102, 255, 0.2)',
                'rgba(255, 159, 64, 0.2)',
                'rgba(255, 205, 86, 0.2)'
              ],
              borderColor: [
                'rgba(255, 99, 132, 1)',
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)',
                'rgba(75, 192, 192, 1)',
                'rgba(153, 102, 255, 1)',
                'rgba(255, 159, 64, 1)',
                'rgba(255, 205, 86, 1)'
              ],
              borderWidth: 1
            }]
          };
        } catch (error) {
          console.error("Error fetching user-specific data", error);
        }
      };
  
      onMounted(() => {
        fetchGeneralGraphsData();
        fetchUserSpecificData();
      });
  
      return {
        registrationData,
        totalHoursData,
        clockEventsData,
        individualHoursData,
        clockInOutData,
        timeAllocationData,
        chartOptions,
      };
    }
  },
  plugins: {
    legend: {
      display: true,
      position: 'top'
    }
  }
});

// Improved date formatting function for Elixir dates
const formatElixirDate = (dateObj) => {
  try {
    if (!dateObj) return null;
    
    // Handle Elixir.Calendar.ISO format
    if (typeof dateObj === 'object' && dateObj.calendar === 'Elixir.Calendar.ISO') {
      const year = dateObj.year || new Date().getFullYear();
      const month = String(dateObj.month).padStart(2, '0');
      const day = String(dateObj.day).padStart(2, '0');
      const hour = String(dateObj.hour || 0).padStart(2, '0');
      const minute = String(dateObj.minute || 0).padStart(2, '0');
      const second = String(dateObj.second || 0).padStart(2, '0');
      
      return `${year}-${month}-${day}`;
    }
    
    // Handle regular date strings
    const date = new Date(dateObj);
    if (!isNaN(date.getTime())) {
      return date.toISOString().split('T')[0];
    }
    
    console.error('Unhandled date format:', dateObj);
    return null;
  } catch (error) {
    console.error('Date formatting error:', error, dateObj);
    return null;
  }
};

const fetchUserRegistrations = async () => {
  try {
    const response = await axios.get(`${API_URL}/users`);
    const users = response.data.data;

    const usersByDate = {};
    users.forEach(user => {
      if (user.inserted_at) {
        const dateStr = formatElixirDate(user.inserted_at);
        if (dateStr) {
          usersByDate[dateStr] = (usersByDate[dateStr] || 0) + 1;
        }
      }
    });

    const sortedDates = Object.keys(usersByDate).sort();
    let cumulative = 0;

    registrationData.value = {
      labels: sortedDates,
      datasets: [{
        label: 'Total Users',
        data: sortedDates.map(date => {
          cumulative += usersByDate[date];
          return cumulative;
        }),
        borderColor: '#4F46E5',
        backgroundColor: 'rgba(79, 70, 229, 0.1)',
        tension: 0.4,
        fill: true
      }]
    };
  } catch (error) {
    console.error('Error fetching user registrations:', error);
  }
};

const fetchClockEvents = async () => {
  if (!userId) {
    console.error('No user ID available');
    return;
  }

  try {
    const response = await axios.get(`${API_URL}/clocks/${userId}`);
    const clocks = response.data.data;

    const clocksByDate = {};
    clocks.forEach(clock => {
      if (clock.time) {
        const dateStr = formatElixirDate(clock.time);
        if (dateStr) {
          if (!clocksByDate[dateStr]) {
            clocksByDate[dateStr] = { clockIns: 0, clockOuts: 0 };
          }
          if (clock.status) {
            clocksByDate[dateStr].clockIns++;
          } else {
            clocksByDate[dateStr].clockOuts++;
          }
        }
      }
    });

    const sortedDates = Object.keys(clocksByDate).sort();

    clockEventsData.value = {
      labels: sortedDates,
      datasets: [
        {
          label: 'Clock Ins',
          data: sortedDates.map(date => clocksByDate[date].clockIns),
          backgroundColor: '#10B981'
        },
        {
          label: 'Clock Outs',
          data: sortedDates.map(date => clocksByDate[date].clockOuts),
          backgroundColor: '#EF4444'
        }
      ]
    };
  } catch (error) {
    console.error('Error fetching clock events:', error);
  }
};

const fetchWorkingTimes = async () => {
  try {
    const response = await axios.get(`${API_URL}/workingtime`);
    const workingTimes = response.data.data;

    const hoursByDate = {};
    workingTimes.forEach(wt => {
      if (wt.start && wt.end) {
        // Format date using the formatElixirDate function for Elixir dates
        const startDateStr = formatElixirDate(wt.start);
        const endDateStr = formatElixirDate(wt.end);
        
        if (startDateStr && endDateStr) {
          const hoursWorked = calculateHours(wt.start, wt.end);
          
          if (hoursWorked >= 1) {
            hoursByDate[startDateStr] = Math.min((hoursByDate[startDateStr] || 0) + hoursWorked, 100);
          }
        }
      }
    });

    const sortedDates = Object.keys(hoursByDate).sort();
    
    workingTimeData.value = {
      labels: sortedDates,
      datasets: [{
        label: 'Total Hours Worked',
        data: sortedDates.map(date => Number(Math.min(hoursByDate[date], 100).toFixed(2))),
        borderColor: '#6366F1',
        backgroundColor: 'rgba(99, 102, 241, 0.1)',
        tension: 0.4,
        fill: true
      }]
    };

    console.log('Working hours by date:', hoursByDate);
  } catch (error) {
    console.error('Error fetching working times:', error);
  }
};

// Helper function to calculate hours between Elixir dates
const calculateHours = (start, end) => {
  if (typeof start === 'object' && start.calendar === 'Elixir.Calendar.ISO' &&
      typeof end === 'object' && end.calendar === 'Elixir.Calendar.ISO') {
    
    const startDate = new Date(
      start.year,
      start.month - 1,
      start.day,
      start.hour || 0,
      start.minute || 0,
      start.second || 0
    );

    const endDate = new Date(
      end.year,
      end.month - 1,
      end.day,
      end.hour || 0,
      end.minute || 0,
      end.second || 0
    );

    return (endDate - startDate) / (1000 * 60 * 60);
  }
  
  // Fallback for regular date strings
  const startTime = new Date(start);
  const endTime = new Date(end);
  return (endTime - startTime) / (1000 * 60 * 60);
};

onMounted(async () => {
  console.log('Fetching data with user ID:', userId);
  await Promise.all([
    fetchUserRegistrations(),
    fetchClockEvents(),
    fetchWorkingTimes()
  ]);
});
</script>

<style scoped>
.chart-container {
  position: relative;
  height: 400px !important;
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  background: white;
  padding: 16px;
  border-radius: 8px;
}

.bg-white {
  max-width: 1200px;
  margin: 0 auto;
}

canvas {
  max-width: 100%;
  max-height: 100%;
}
</style>