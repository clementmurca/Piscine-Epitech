<script setup>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import Navbar from './components/Navbar.vue';
import { HomeIcon, UsersIcon, UserGroupIcon, ClockIcon, ChartSquareBarIcon } from '@heroicons/vue/outline';

const route = useRoute();
const userId = ref(null);
const userRole = ref('');

// Fonction pour récupérer l'ID et le rôle de l'utilisateur
const updateUserId = () => {
  const user = localStorage.getItem('user');
  if (user) {
    const parsedUser = JSON.parse(user);
    userId.value = parsedUser.id; 
    userRole.value = parsedUser.role; 
  } else {
    userId.value = null; 
    userRole.value = ''; 
  }
};

onMounted(() => {
  updateUserId();
});

const isMobile = ref(window.innerWidth < 768);
window.addEventListener('resize', () => {
  isMobile.value = window.innerWidth < 768;
});
</script>

<template>
  <template v-if="route.path === '/login' || route.path === '/register'">
    <router-view></router-view>
  </template>

  <template v-else>
    <div class="flex flex-col h-screen bg-gray-900 text-white">
      <!-- Navbar -->
      <nav class="">
        <Navbar/>
      </nav>

      <div class="flex flex-1 overflow-hidden">
        <!-- Sidebar -->
        <aside v-if="!isMobile" class="w-64 bg-gray-800 shadow-lg transition-transform duration-300 transform hover:scale-105">
          <div class="flex flex-col h-full">
            <div class="flex items-center justify-start h-16 p-4">
              <img src="./image/logo.png" alt="Logo" class="h-12 w-14 rounded-full mr-2"> 
              <span class="text-xl font-bold">Time Manager</span>
            </div>
            <nav class="flex-1 p-4 space-y-2">
              <router-link :to="`/clock/${userId}`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                <HomeIcon class="w-6 h-6" />
                <span class="ml-3">Home</span>
              </router-link>

              <template v-if="['Admin', 'general_manager'].includes(userRole)">
                <router-link to="/users" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <UsersIcon class="w-6 h-6" />
                  <span class="ml-3">Users</span>
                </router-link>
                <router-link to="/teams" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <UserGroupIcon class="w-6 h-6" />
                  <span class="ml-3">Teams</span>
                </router-link>
                <router-link :to="`/working-time/${userId}`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ClockIcon class="w-6 h-6" />
                  <span class="ml-3">Working Time</span>
                </router-link>
              </template>

              <template v-if="userRole !== 'employee'">
                <router-link :to="`/working-times/${userId}`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ClockIcon class="w-6 h-6" />
                  <span class="ml-3">Working Times</span>
                </router-link>
                <router-link :to="`/clock/${userId}`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ClockIcon class="w-6 h-6" />
                  <span class="ml-3">Clocks</span>
                </router-link>
                <router-link :to="`/chartManager/${userId}`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ChartSquareBarIcon class="w-6 h-6" />
                  <span class="ml-3">Charts</span>
                </router-link>
                <router-link :to="`/userDashboard`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ChartSquareBarIcon class="w-6 h-6" />
                  <span class="ml-3">User Charts</span>
                </router-link>
              </template>

              <template v-else-if="userRole === 'manager'">
                <router-link :to="`/working-times/${userId}`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ClockIcon class="w-6 h-6" />
                  <span class="ml-3">Working Times</span>
                </router-link>
                <router-link :to="`/working-time/${userId}`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ClockIcon class="w-6 h-6" />
                  <span class="ml-3">Working Time</span>
                </router-link>
                <router-link :to="`/clock/${userId}`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ClockIcon class="w-6 h-6" />
                  <span class="ml-3">Clocks</span>
                </router-link>
              
                <router-link :to="`/userDashboard`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ChartSquareBarIcon class="w-6 h-6" />
                  <span class="ml-3">User Charts</span>
                </router-link>
              </template>

              <template v-else-if="userRole === 'employee'">
                <router-link :to="`/working-times/${userId}`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ClockIcon class="w-6 h-6" />
                  <span class="ml-3">Working Times</span>
                </router-link>
                <router-link :to="`/clock/${userId}`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ClockIcon class="w-6 h-6" />
                  <span class="ml-3">Clocks</span>
                </router-link>
                <router-link :to="`/userDashboard`" class="flex items-center p-3 rounded-lg hover:bg-blue-600 transition duration-300 transform hover:translate-x-2">
                  <ChartSquareBarIcon class="w-6 h-6" />
                  <span class="ml-3">User Charts</span>
                </router-link>
              </template>
            </nav>
          </div>
        </aside>

        <!-- Tabbar pour mobile -->
        <nav v-else class="fixed bottom-0 left-0 right-0 bg-gradient-to-r from-blue-500 to-indigo-600 flex justify-around py-2 shadow-lg">
          <router-link :to="`/clock/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
            <HomeIcon class="w-6 h-6" />
          </router-link>

          <template v-if="['Admin', 'general_manager'].includes(userRole)">
            <router-link to="/users" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <UsersIcon class="w-6 h-6" />
            </router-link>
            <router-link to="/teams" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <UserGroupIcon class="w-6 h-6" />
            </router-link>
          </template>

          <template v-if="userRole !== 'employee'">
            <router-link :to="`/working-times/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <ClockIcon class="w-6 h-6" />
            </router-link>
            <router-link :to="`/clock/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <ClockIcon class="w-6 h-6" />
            </router-link>
            <router-link :to="`/working-time/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <ClockIcon class="w-6 h-6" />
            </router-link>
            <router-link :to="`/chartManager/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <ChartSquareBarIcon class="w-6 h-6" />
            </router-link>
       
          </template>

          <template v-else-if="userRole === 'manager'">
            <router-link :to="`/working-times/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <ClockIcon class="w-6 h-6" />
            </router-link>
            <router-link :to="`/clock/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <ClockIcon class="w-6 h-6" />
            </router-link>
            <router-link :to="`/chartManager/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <ChartSquareBarIcon class="w-6 h-6" />
            </router-link>
          </template>

          <template v-else-if="userRole === 'employee'">
            <router-link :to="`/working-times/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <ClockIcon class="w-6 h-6" />
            </router-link>
            <router-link :to="`/clock/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <ClockIcon class="w-6 h-6" />
            </router-link>
            <router-link :to="`/chartManager/${userId}`" class="flex flex-col items-center text-white hover:text-purple-300 transition duration-300">
              <ChartSquareBarIcon class="w-6 h-6" />
            </router-link>
          </template>
        </nav>

        <!-- Main Content -->
        <main class="flex-1 p-8 overflow-y-auto bg-gray-100">
          <router-view></router-view>
        </main>
      </div>
    </div>
  </template>
</template>

<style scoped>
@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

.logo {
  animation: bounce 1s infinite;
}
</style>
