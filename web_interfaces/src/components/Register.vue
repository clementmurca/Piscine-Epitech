<template>
  <div class="flex items-center justify-center min-h-screen bg-gray-800">
    
    <div class="flex flex-col lg:flex-row bg-white p-10 rounded-lg shadow-lg w-11/12 max-w-5xl">
      
      <img src="@/image/login.png" class="w-full lg:w-1/2 object-cover mb-6 lg:mb-0" alt="Register Image">

      <!-- Register Form -->
      <div class="w-full lg:w-1/2 flex flex-col justify-center px-6 lg:px-10">
        <h2 class="text-3xl font-bold text-gray-800 mb-8 text-center">Register</h2>
        <form @submit.prevent="Register" class="space-y-6">
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
            <input
              v-model="formRegisterData.email"
              type="email"
              name="email"
              id="email"
              class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              placeholder="John.Doe@example.com"
              required
            />
          </div>
          <div>
            <label for="username" class="block text-sm font-medium text-gray-700">Username</label>
            <input
              v-model="formRegisterData.username"
              type="text"
              name="username"
              id="username"
              class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              placeholder="Username"
              required
            />
          </div>
          <div>
            <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
            <input
              v-model="formRegisterData.password"
              type="password"
              name="password"
              id="password"
              class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              placeholder="Password"
              required
            />
          </div>
          <button
            type="submit"
            class="w-full py-2 px-4 bg-indigo-600 text-white font-semibold rounded-lg shadow-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
          >
            Register
          </button>
        </form>
        <p v-if="error" class="mt-4 text-sm text-red-500">{{ error }}</p>
        <p class="mt-4 text-sm text-gray-500">
          Already have an account? 
          <router-link to="/login" class="text-indigo-600 hover:text-indigo-800">Login</router-link>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import axios from 'axios';
import Toastify from 'toastify-js';
import "toastify-js/src/toastify.css";
import { ref } from 'vue';
import { useRouter } from 'vue-router'; 

const router = useRouter(); 

const API_URL = process.env.TIME_MANAGER_APP_URL || 'http://localhost:4000/api';
const error = ref('');

const showToast = (message, type = 'success') => {
  Toastify({
    text: message,
    duration: 3000,
    close: true,
    gravity: "top",
    position: "right",
    background: type === 'success' ? "#4CAF50" : "#F44336",
  }).showToast();
};

const formRegisterData = ref({
  email: '',
  username: '',
  password: ''
});

const Register = async () => {
  try {
    const data = {
      user: {
        email: formRegisterData.value.email,
        username: formRegisterData.value.username,
        password: formRegisterData.value.password
      }
    };
    const response = await axios.post(`${API_URL}/users`, data);
    console.log('Register successful:', response.data);
    showToast('Registration successful');
    router.push('/login');
  } catch (error) {
    console.error('Error registration:', error.response ? error.response.data : error);
    showToast('Registration failed.', 'error');
  }
};
</script>
