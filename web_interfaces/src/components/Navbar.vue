<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { faSignOutAlt, faUser } from '@fortawesome/free-solid-svg-icons'; 


const user = ref(JSON.parse(localStorage.getItem('user')));
const router = useRouter();


const logout = () => {
  localStorage.removeItem('user');
  localStorage.removeItem('xsrf_token');
  document.cookie = 'jwt=; Max-Age=0; path=/';
  router.push('/login').then(() => {
  });
};

const goToProfile = () => {
  router.push('/profile');
};
</script>

<template>
  <nav class="bg-gradient-to-r from-blue-500 to-indigo-600  shadow-lg text-white p-4">
    <div class="container mx-auto flex justify-between items-center">
      <div class="text-lg font-semibold">
        Welcome, {{ user?.username || 'Guest' }} to your {{ user?.role }} dashboard !
      </div>
       
      <div class="flex space-x-4">
        <!-- Profile Icon -->
        <button @click="goToProfile" class="hover:text-gray-200">
          <FontAwesomeIcon :icon="faUser" size="lg" />
        </button>
        
        <!-- Logout Icon -->
        <button @click="logout" class="hover:text-gray-200">
          <FontAwesomeIcon :icon="faSignOutAlt" size="lg" />
        </button>
      </div>
    </div>
  </nav>
</template>

<style scoped>
/* Optional: Add custom styling */
button {
  background: none;
  border: none;
  cursor: pointer;
  color: inherit;
}
</style>