<template>
  <div class="p-6 bg-gray-100 min-h-screen">
    <h1 class="text-3xl font-bold text-center text-blue-600 mb-8">Dashboard</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
      <!-- Clock In Component -->
      <div class="col-span-1">
        <!-- Assure-toi que userId est défini avant de passer au composant -->
        <ClockManager v-if="userId" :userId="userId" />
      </div>

      <!-- User-Specific Graphs Section -->
      <div class="col-span-1 md:col-span-2 lg:col-span-3">
        <h2 class="text-2xl font-semibold text-gray-700 mt-4 mb-4">User-Specific Graphs</h2>

        <!-- Individual Working Hours per Day -->
        <div v-if="individualHoursData.datasets.length > 0" class="mb-8">
          <h3 class="text-xl font-medium text-gray-600 mb-2">Individual Working Hours per Day</h3>
          <Bar :data="individualHoursData" :options="chartOptions" class="chart-container" />
        </div>

        <!-- Individual Clock-in/Clock-out Events by Time -->
        <div v-if="clockInOutData.datasets.length > 0" class="mb-8">
          <h3 class="text-xl font-medium text-gray-600 mb-2">Individual Clock-in/Clock-out Events by Time</h3>
          <Line :data="clockInOutData" :options="chartOptions" class="chart-container" />
        </div>

        <!-- Individual Time Allocation -->
        <div v-if="timeAllocationData.datasets.length > 0" class="mb-8">
          <h3 class="text-xl font-medium text-gray-600 mb-2">Individual Time Allocation</h3>
          <Doughnut :data="timeAllocationData" :options="chartOptions" class="chart-container" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import ClockManager from './ClockManager.vue';
import { Bar, Line, Doughnut } from 'vue-chartjs'; 
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale } from 'chart.js';
import axios from 'axios';

// Enregistrement des composants de chart.js
ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale);

// Récupération de l'utilisateur depuis le localStorage
const user = JSON.parse(localStorage.getItem('user'));
const userId =user.id;

const API_URL = process.env.TIME_MANAGER_APP_URL || 'http://localhost:4000/api';
const individualHoursData = ref({ labels: [], datasets: [] });
const clockInOutData = ref({ labels: [], datasets: [] });
const timeAllocationData = ref({ labels: [], datasets: [] });

const chartOptions = ref({
  responsive: true,
  maintainAspectRatio: true,
  scales: {
    x: {
      ticks: { maxRotation: 45, minRotation: 45 }
    },
    y: {
      beginAtZero: true
    }
  }
});

// Fonction pour récupérer les données spécifiques à l'utilisateur
const fetchUserSpecificData = async () => {
  if (!userId.value) return;  // S'assure que l'utilisateur est connecté

  try {
    const [userWorkResponse, userClockResponse] = await Promise.all([
      axios.get(`${API_URL}/workingtime/${userId.value}`),
      axios.get(`${API_URL}/clocks/${userId.value}`)
    ]);

    // Traitement des données de temps de travail
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

    // Traitement des données d'horloge
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

    // Allocation du temps
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

// Traitement des heures de travail individuelles
const processIndividualWorkHours = (data) => {
  const dailyHours = {};
  data.forEach(entry => {
    const date = new Date(entry.start).toLocaleDateString('en-US');
    const hoursWorked = (new Date(entry.end) - new Date(entry.start)) / (1000 * 60 * 60);
    dailyHours[date] = (dailyHours[date] || 0) + hoursWorked;
  });
  return { labels: Object.keys(dailyHours), data: Object.values(dailyHours) };
};

// Traitement des données d'horloge
const processClockInOutData = (data) => {
  const labels = [];
  const times = [];
  data.forEach(entry => {
    labels.push(new Date(entry.time).toLocaleDateString('en-US'));
    times.push(new Date(entry.time).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }));
  });
  return { labels, data: times };
};

// Allocation du temps
const processTimeAllocationData = (data) => {
  const total = data.datasets[0].data.reduce((acc, val) => acc + val, 0);
  const values = data.datasets[0].data.map(val => (val / total) * 100);
  return { labels: data.labels, data: values };
};

onMounted(() => {
  fetchUserSpecificData();
});
</script>

<style scoped>
.chart-container {
  height: 300px;
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
}
</style>
