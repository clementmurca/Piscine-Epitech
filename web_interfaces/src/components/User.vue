<template>
  <div class="p-4">
    <h2 class="text-4xl font-bold mb-6 text-gray-800 bg-gradient-to-r from-blue-500 to-indigo-600 text-transparent bg-clip-text">
      Users
    </h2>

    <button @click="openModal('create')" 
        class="flex items-center bg-gradient-to-r from-blue-500 to-indigo-600 text-white font-semibold px-6 py-3 rounded-lg mb-6 transition transform duration-200 hover:scale-105 shadow-lg">
        <UserAddIcon class="w-5 h-5 mr-2" />
        Create User
    </button>

    <div class="overflow-x-auto">
      <table class="min-w-full bg-white shadow-md rounded">
        <thead>
          <tr class="bg-blue-50 text-gray-600 text-sm uppercase leading-normal">
            <th class="py-3 px-6 text-left">ID</th>
            <th class="py-3 px-6 text-left">Username</th>
            <th class="py-3 px-6 text-left">Email</th>
            <th class="py-3 px-6 text-left">Role</th>
            <th class="py-3 px-6 text-center">Actions</th>
          </tr>
        </thead>
        <tbody class="text-gray-600 text-sm font-light">
          <tr v-for="user in users" :key="user.id" class="border-b border-gray-200 hover:bg-gray-100">
            <td class="py-3 px-6 text-left">{{ user.id }}</td>
            <td class="py-3 px-6 text-left">{{ user.username }}</td>
            <td class="py-3 px-6 text-left">{{ user.email }}</td>
            <td class="py-3 px-6 text-left">{{ user.role }}</td>
            <td class="py-3 px-6 text-center flex justify-center space-x-2">
              <button @click="openModal('edit', user)" class="text-yellow-500 hover:text-yellow-700">
                <PencilIcon class="h-5 w-5" />
              </button>
              <button @click="deleteUser(user.id)" class="text-red-500 hover:text-red-700">
                <TrashIcon class="h-5 w-5" />
              </button>
              <button @click="openRoleModal(user)" class="flex items-center text-blue-500 hover:text-blue-700 transition duration-200 transform hover:scale-105">
                <AdjustmentsIcon class="h-5 w-5 mr-2" />
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal pour la création/mise à jour de l'utilisateur -->
    <div v-if="showModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <h3 class="text-lg font-bold mb-4">{{ modalMode === 'create' ? 'Create' : 'Edit' }} User</h3>
        <form @submit.prevent="modalMode === 'create' ? createUser() : updateUser()">
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="username">
              Username
            </label>
            <input v-model="formData.username" type="text" id="username" required
              class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline">
          </div>
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="email">
              Email
            </label>
            <input v-model="formData.email" type="email" id="email" required
              class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline">
          </div>
          <div class="flex items-center justify-between">
            <button type="submit"
            class="bg-gradient-to-r from-blue-500 to-indigo-600 text-white px-4 py-2 rounded hover:from-blue-600 hover:to-indigo-700">
              {{ modalMode === 'create' ? 'Create' : 'Update' }}
            </button>
            <button @click="closeModal" type="button"
              class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline">
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal pour changer le rôle -->
    <div v-if="showRoleModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <h3 class="text-lg font-bold mb-4">Change Role for {{ roleFormData.username }}</h3>
        <form @submit.prevent="changeUserRole">
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="role">
              Select Role
            </label>
            <select v-model="roleFormData.role" id="role" required
              class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline">
              <option value="Admin">Admin</option>
              <option value="manager">Manager</option>
              <option value="general_manager">General Manager</option>
              <option value="employee">Employee</option>
            </select>
          </div>
          <div class="flex items-center justify-between">
            <button type="submit"
              class="bg-gradient-to-r from-blue-500 to-indigo-600 text-white px-4 py-2 rounded hover:from-blue-600 hover:to-indigo-700">
              Update Role
            </button>
            <button @click="closeRoleModal" type="button"
              class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline">
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import Toastify from 'toastify-js';
import "toastify-js/src/toastify.css";
import { PencilIcon, TrashIcon, UserAddIcon, AdjustmentsIcon } from '@heroicons/vue/outline'; 

const API_URL = process.env.TIME_MANAGER_APP_URL || 'http://localhost:4000/api';
const users = ref([]);
const showModal = ref(false);
const showRoleModal = ref(false); 
const modalMode = ref('create');
const formData = ref({
  id: '',
  username: '',
  email: ''
});

const roleFormData = ref({
  id: '',
  username: '',
  role: '' 
});

onMounted(async () => {
  await fetchUsers();
});

const fetchUsers = async () => {
  try {
    const response = await axios.get(`${API_URL}/users`);
    users.value = Array.isArray(response.data.data) ? response.data.data : [];
    console.log('Fetched users:', users.value);
  } catch (error) {
    console.error('Error fetching users:', error);
    showToast('Error fetching users', 'error');
  }
};

const openModal = (mode, user = null) => {
  modalMode.value = mode;
  if (mode === 'edit' && user) {
    formData.value = { ...user };
  } else {
    formData.value = { id: '', username: '', email: '' };
  }
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
};

const openRoleModal = (user) => {
  roleFormData.value = { id: user.id, username: user.username, role: user.role };
  showRoleModal.value = true;
};

const closeRoleModal = () => {
  showRoleModal.value = false;
};

const createUser = async () => {
  try {
    const response = await axios.post(`${API_URL}/users, { user: formData.value }`);
    console.log('Server response:', response.data);
    await fetchUsers();
    closeModal();
    showToast('User created successfully!');
  } catch (error) {
    console.error('Error creating user:', error.response ? error.response.data : error);
    showToast('Error creating user', 'error');
  }
};

const updateUser = async () => {
  try {
    console.log('formData before update:', formData.value); 
    const response = await axios.put(`${API_URL}/users/${formData.value.id}`, { user: formData.value });
    console.log('Server response:', response.data);
    await fetchUsers(); 
    closeModal();
    showToast('User updated successfully!');
  } catch (error) {
    console.error('Error updating user:', error.response ? error.response.data : error);
    showToast('Error updating user', 'error');
  }
};

const deleteUser = async (id) => {
  if (!confirm('Are you sure you want to delete this user?')) {
    return;
  }
  try {
    const response = await axios.delete(`${API_URL}/users/${id}`);
    console.log('Server response:', response.data);
    await fetchUsers();
    showToast('User deleted successfully!');
  } catch (error) {
    console.error('Error deleting user:', error.response ? error.response.data : error);
    showToast('Error deleting user', 'error');
  }
};

const changeUserRole = async () => {
  try {
    const response = await axios.put(`${API_URL}/users/${roleFormData.value.id}/role`, { role: roleFormData.value.role });
    console.log('Server response:', response.data);
    await fetchUsers();
    closeRoleModal();
    showToast('User role updated successfully!');
  } catch (error) {
    console.error('Error updating user role:', error.response ? error.response.data : error);
    showToast('Error updating user role', 'error');
  }
};

const showToast = (message, type = 'success') => {
  Toastify({
    text: message,
    duration: 3000,
    gravity: 'top', 
    position: 'center',
    backgroundColor: type === 'success' ? 'linear-gradient(to right, #00b09b, #96c93d)' : 'linear-gradient(to right, #FF5F6D, #FFC371)',
    stopOnFocus: true, 
  }).showToast();
};
</script>

<style>
@import 'toastify-js/src/toastify.css';
</style>