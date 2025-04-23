<template>
    <div class="flex items-center justify-center min-h-screen bg-white">
      <div class="bg-white p-8 rounded-lg shadow-lg w-3/4 max-w-lg">
        <h2 class="text-3xl font-bold text-gray-800 mb-8 text-center">Profile</h2>
  
        <!-- Display current user information -->
        <form @submit.prevent="updateProfile">
          <div class="mb-6">
            <label for="username" class="block text-sm font-medium text-gray-700">Username</label>
            <input
              v-model="form.username"
              type="text"
              id="username"
              class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            />
          </div>
  
          <div class="mb-6">
            <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
            <input
              v-model="form.email"
              type="email"
              id="email"
              class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            />
          </div>
  
          <div class="mb-6">
            <label for="password" class="block text-sm font-medium text-gray-700">New Password</label>
            <input
              v-model="form.password"
              type="password"
              id="password"
              placeholder="Enter new password"
              class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            />
          </div>
  
          <!-- Update Profile Button -->
          <button
            type="submit"
            class="w-full py-2 px-4 bg-indigo-600 text-white font-semibold rounded-lg shadow-md hover:bg-indigo-700 focus:ring-indigo-500"
          >
            Update Profile
          </button>
        </form>
  
        <!-- Display User Role -->
        <p class="mt-4 text-center text-gray-500">Role: {{ user?.role }}</p>
  
        <!-- Logout and Delete Account -->
        <div class="mt-6 flex justify-between">
          <button
            @click="logout"
            class="py-2 px-4 bg-red-500 text-white font-semibold rounded-lg shadow-md hover:bg-red-600 focus:ring-red-500"
          >
            Logout
          </button>
  
          <button
            @click="deleteAccount"
            class="py-2 px-4 bg-gray-500 text-white font-semibold rounded-lg shadow-md hover:bg-gray-600 focus:ring-gray-500"
          >
            Delete Account
          </button>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue'
  import axios from 'axios'
  import { useRouter } from 'vue-router'
  
  const router = useRouter()
  
  // API URL for your backend
  const API_URL = process.env.TIME_MANAGER_APP_URL || 'http://localhost:4000/api'
  
  // Form state for user profile data
  const form = ref({
    username: '',
    email: '',
    password: ''  // for updating the password
  })
  
  // Store the logged-in user data
  const user = ref(JSON.parse(localStorage.getItem('user')))
  
  // Fetch the user's profile when the component mounts
  onMounted(async () => {
    try {
      const { data } = await axios.get(`${API_URL}/users/${user.value.id}`)
      form.value.username = data.data.username
      form.value.email = data.data.email
      user.value.role = data.data.role // Set user role for display
    } catch (error) {
      console.error('Error fetching profile:', error.response ? error.response.data : error)
    }
  })
  
  // Update user profile (username, email, password)
  const updateProfile = async () => {
    try {
      const userId = user.value.id
      const updateData = {
        username: form.value.username,
        email: form.value.email,
        password: form.value.password
      } // Send the updated user data
      const response = await axios.put(`${API_URL}/users/${userId}`, { user: updateData })
  
      console.log('Profile updated successfully:', response.data)
      alert('Profile updated successfully!')
      form.value.password = ''  // Clear password input after update
    } catch (error) {
      console.error('Error updating profile:', error.response ? error.response.data : error)
      alert('Failed to update profile.')
    }
  }
  
  // Logout function
  const logout = async () => {
    try {
      await axios.post(`${API_URL}/logout`)
      localStorage.removeItem('user')
      router.push('/login')
    } catch (error) {
      console.error('Error logging out:', error.response ? error.response.data : error)
    }
  }
  
  // Delete account function
  const deleteAccount = async () => {
    try {
      const userId = user.value.id
      await axios.delete(`${API_URL}/profile`)
      localStorage.removeItem('user')
      router.push('/login')
      alert('Account deleted successfully.')
    } catch (error) {
      console.error('Error deleting account:', error.response ? error.response.data : error)
      alert('Failed to delete account.')
    }
  }
  </script>
  
  <style scoped>
  /* Styling to remove the gray background and give a clean look */
  body {
    background-color: white;
  }
  
  .bg-white {
    background-color: white;
  }
  
  .mt-4 {
    margin-top: 1rem;
  }
  
  .mb-6 {
    margin-bottom: 1.5rem;
  }
  
  .rounded-lg {
    border-radius: 0.5rem;
  }
  
  .shadow-lg {
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  }
  
  button {
    transition: background-color 0.2s ease;
  }
  </style>
  