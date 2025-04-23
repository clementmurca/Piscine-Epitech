<template>
    <div class="p-8 bg-gray-100 min-h-screen">
      <!-- User Selection -->
      <div class="mb-8 bg-white p-6 rounded-lg shadow">
        <h2 class="text-2xl font-semibold text-gray-700 mb-4">User Dashboard</h2>
        <div class="flex gap-4 items-center mb-6">
          <select 
            v-model="selectedUserId" 
            @change="fetchUserData"
            class="p-2 border rounded-md min-w-[200px]"
          >
            <option value="">Select User</option>
            <option 
              v-for="user in users" 
              :key="user.id" 
              :value="user.id"
            >
              {{ user.username }} (ID: {{ user.id }})
            </option>
          </select>
        </div>
      </div>
  
      <!-- Clock Events Chart -->
      <div class="mb-8 bg-white p-6 rounded-lg shadow">
        <h2 class="text-2xl font-semibold text-gray-700 mb-4">Clock Events</h2>
        <div class="chart-container">
          <Bar
            v-if="clockEventsData.datasets && clockEventsData.datasets.length > 0"
            :data="clockEventsData"
          />
          <div v-else class="flex items-center justify-center h-full">
            <p class="text-gray-500">Select a user to view clock events</p>
          </div>
        </div>
      </div>
  
      <!-- Effective Working Hours Chart -->
      <div class="mb-8 bg-white p-6 rounded-lg shadow">
        <h2 class="text-2xl font-semibold text-gray-700 mb-4">Effective Working Hours</h2>
        <div class="chart-container">
          <Line
            v-if="effectiveHoursData.datasets && effectiveHoursData.datasets.length > 0"
            :data="effectiveHoursData"
            :options="chartOptions"
          />
          <div v-else class="flex items-center justify-center h-full">
            <p class="text-gray-500">Select a user to view effective hours</p>
          </div>
        </div>
      </div>
  
      <!-- Allocated Working Time Chart -->
      <div class="mb-8 bg-white p-6 rounded-lg shadow">
        <h2 class="text-2xl font-semibold text-gray-700 mb-4">Allocated Working Time</h2>
        <div class="chart-container">
          <Line
            v-if="allocatedTimeData.datasets && allocatedTimeData.datasets.length > 0"
            :data="allocatedTimeData"
          />
          <div v-else class="flex items-center justify-center h-full">
            <p class="text-gray-500">Select a user to view allocated time</p>
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
    BarElement,
    Filler
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
    Legend,
    Filler
    
  );
  
  const API_URL = process.env.TIME_MANAGER_APP_URL || 'http://localhost:4000/api';
  const currentUser = JSON.parse(localStorage.getItem('user'));
  const users = ref([]);
  const selectedUserId = ref(currentUser?.id || '');
  
  const clockEventsData = ref({ labels: [], datasets: [] });
  const effectiveHoursData = ref({ labels: [], datasets: [] });
  const allocatedTimeData = ref({ labels: [], datasets: [] });
  
  // Fetch users for dropdown
  const fetchUsers = async () => {
    try {
      const response = await axios.get(`${API_URL}/users`);
      users.value = response.data.data;
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };
  
  // Format Elixir date
  const formatElixirDate = (dateObj) => {
    if (typeof dateObj === 'object' && dateObj.calendar === 'Elixir.Calendar.ISO') {
      const year = dateObj.year;
      const month = String(dateObj.month).padStart(2, '0');
      const day = String(dateObj.day).padStart(2, '0');
      return `${year}-${month}-${day}`;
    }
    const date = new Date(dateObj);
    return date.toISOString().split('T')[0];
  };
  
  // Calculate hours between two dates
  const calculateHours = (start, end) => {
    const startDate = typeof start === 'object' ? 
      new Date(start.year, start.month - 1, start.day, start.hour || 0, start.minute || 0) :
      new Date(start);
    
    const endDate = typeof end === 'object' ? 
      new Date(end.year, end.month - 1, end.day, end.hour || 0, end.minute || 0) :
      new Date(end);
  
    return (endDate - startDate) / (1000 * 60 * 60);
  };
  
  // Fetch clock events
  const fetchClockEvents = async (userId) => {
    try {
      const response = await axios.get(`${API_URL}/clocks/${userId}`);
      const clocks = response.data.data;
  
      const clocksByDate = {};
      clocks.forEach(clock => {
        if (clock.time) {
          const dateStr = formatElixirDate(clock.time);
          if (!clocksByDate[dateStr]) {
            clocksByDate[dateStr] = { clockIns: 0, clockOuts: 0 };
          }
          if (clock.status) {
            clocksByDate[dateStr].clockIns++;
          } else {
            clocksByDate[dateStr].clockOuts++;
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
  
  // Calculate effective working hours from clock events
  const calculateEffectiveHours = async (userId) => {
    try {
    const response = await axios.get(`${API_URL}/clocks/${userId}`);
    const clocks = response.data.data;

    // Group clocks by date first
    const clocksByDate = {};
    
    clocks.forEach(clock => {
      // Handle Elixir calendar format
      let clockTime;
      if (clock.time?.calendar === 'Elixir.Calendar.ISO') {
        clockTime = new Date(
          clock.time.year,
          clock.time.month - 1,
          clock.time.day,
          clock.time.hour || 0,
          clock.time.minute || 0,
          clock.time.second || 0
        );
      } else {
        clockTime = new Date(clock.time);
      }

      const dateStr = clockTime.toISOString().split('T')[0];
      
      if (!clocksByDate[dateStr]) {
        clocksByDate[dateStr] = [];
      }
      clocksByDate[dateStr].push({
        time: clockTime,
        status: clock.status
      });
    });

    // Calculate hours for each date
    const dailyHours = {};
    
    Object.entries(clocksByDate).forEach(([date, dayClocks]) => {
      // Sort clocks by time
      dayClocks.sort((a, b) => a.time - b.time);
      
      let dayTotal = 0;
      let lastClockIn = null;

      dayClocks.forEach(clock => {
        if (clock.status) {
          lastClockIn = clock.time;
        } else if (!clock.status && lastClockIn) {
          const duration = (clock.time - lastClockIn) / (1000 * 60 * 60);
          dayTotal += duration;
          lastClockIn = null;
        }
      });

      console.log(`Hours for ${date}:`, dayTotal);
      if (dayTotal >= 1) {
        dailyHours[date] = Number(dayTotal.toFixed(2));
      }
    });

    console.log('Daily hours before filtering:', dailyHours);

    // Convert to chart data
    const sortedDates = Object.keys(dailyHours).sort();
    
    effectiveHoursData.value = {
      labels: sortedDates,
      datasets: [{
        label: 'Effective Working Hours',
        data: sortedDates.map(date => dailyHours[date]),
        borderColor: '#6366F1',
        backgroundColor: 'rgba(99, 102, 241, 0.1)',
        tension: 0.1,
        fill: true,
        pointRadius: 4,
        pointHoverRadius: 6
      }]
    };

    console.log('Chart data prepared:', {
      labels: sortedDates,
      data: sortedDates.map(date => dailyHours[date])
    });

  } catch (error) {
    console.error('Error calculating effective hours:', error);
  }
};
  
const chartOptions = {
    responsive: true,
  maintainAspectRatio: false,
  scales: {
    y: {
      beginAtZero: true,
      max: 24,
      ticks: {
        stepSize: 2,
        callback: value => `${value}h`
      }
    },
    x: {
      grid: {
        display: false
      }
    }
  },
  plugins: {
    tooltip: {
      callbacks: {
        label: function(context) {
          return `${context.raw} hours worked`;
        }
      }
    }
  }
};


  // Fetch allocated working times
  const fetchAllocatedTime = async (userId) => {
    try {
    console.log('Attempting to fetch allocated time for user ID:', userId);

    if (!userId) {
      console.error('No user ID provided for fetchAllocatedTime');
      return;
    }

    const token = localStorage.getItem('jwt');
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };
    // Change the URL to match the correct route for list_wt_user
    const url = `${API_URL}/workingtimes/${userId}` ;
    console.log('Calling API endpoint:', url);

    const response = await axios.get(url);
    
    if (!response.data || !response.data.data) {
      console.error('No data received from API');
      allocatedTimeData.value = { labels: [], datasets: [] };
      return;
    }

    const workingTimes = response.data.data;
    console.log('Working times received:', workingTimes);

    const hoursByDate = {};
    workingTimes.forEach(wt => {
      if (wt.start && wt.end) {
        const dateStr = formatElixirDate(wt.start);
        const hoursWorked = calculateHours(wt.start, wt.end);
        if (hoursWorked >= 1) {
          hoursByDate[dateStr] = (hoursByDate[dateStr] || 0) + hoursWorked;
        }
      }
    });

    const sortedDates = Object.keys(hoursByDate).sort();

    if (sortedDates.length > 0) {
      allocatedTimeData.value = {
        labels: sortedDates,
        datasets: [{
          label: `Allocated Hours (User ${userId})`,
          data: sortedDates.map(date => Number(hoursByDate[date].toFixed(2))),
          borderColor: '#8B5CF6',
          backgroundColor: 'rgba(139, 92, 246, 0.1)',
          tension: 0.1,
          fill: true,
          pointRadius: 4,
          pointHoverRadius: 6
        }]
      };
    } else {
      allocatedTimeData.value = { labels: [], datasets: [] };
    }

    console.log(`Allocated hours for user ${userId}:`, hoursByDate);
  } catch (error) {
    console.error(`Error fetching allocated time for user ${userId}:`, {
      error: error.message,
      response: error.response?.data,
      status: error.response?.status
    });
    allocatedTimeData.value = { labels: [], datasets: [] };
  }
};

// Update the fetchUserData function to ensure userId is passed
const fetchUserData = async () => {
  if (!selectedUserId.value) {
    console.error('No user selected');
    return;
  }
  
  console.log('Fetching data for user:', selectedUserId.value);
  
  await Promise.all([
    fetchClockEvents(selectedUserId.value),
    calculateEffectiveHours(selectedUserId.value),
    fetchAllocatedTime(selectedUserId.value)
  ]);
};
  
 
  onMounted(async () => {
    await fetchUsers();
    if (selectedUserId.value) {
      await fetchUserData();
    }
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

  select {
  color: initial; 
}
  </style>