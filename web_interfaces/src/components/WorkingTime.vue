<template> 
    <div class="p-4 bg-gray-100 min-h-screen">
        <h2 class="text-4xl font-bold mb-6 text-gray-800 bg-gradient-to-r from-blue-500 to-indigo-600 text-transparent bg-clip-text">
            Working Time
        </h2>
  
      <button @click="openModal('create')" 
              class="flex items-center bg-gradient-to-r from-blue-500 to-indigo-600 text-white font-semibold px-6 py-3 rounded-lg mb-6 transition transform duration-200 hover:scale-105 shadow-lg">
        <PlusCircleIcon class="w-5 h-5 mr-2" />
        Create Working Time
      </button>
  
      <div class="overflow-x-auto shadow-lg rounded-lg bg-white">
        <table class="min-w-full bg-white rounded-lg">
          <thead>
            <tr class="bg-blue-50 text-gray-600 text-sm uppercase leading-normal">
              <th class="py-2 px-4 text-left ">Start</th>
              <th class="py-2 px-4 text-left ">End</th>
              <th class="py-2 px-4 text-center ">User ID</th>
              <th class="py-2 px-4 text-center">Actions</th>
            </tr>
          </thead>
          <tbody class="text-gray-700 text-sm">
            <tr v-for="wt in workingTimes" :key="wt.id" class="border-b border-gray-100 hover:bg-blue-50 transition duration-200">
              <td class="py-2 px-4">{{ formatDate(wt.start) }}</td>
              <td class="py-2 px-4">{{ formatDate(wt.end) }}</td>
              <td class="py-2 px-4 text-center">{{ wt.user_id }}</td>
              <td class="py-2 px-4 flex justify-center space-x-2 text-gray-500">
                <button @click="openModal('edit', wt)" class=" text-yellow-500 hover:text-yellow-700 transition duration-300">
                  <PencilIcon class="w-5 h-5" />
                </button>
                <button @click="deleteWorkingTime(wt.id)" class="text-red-500 hover:text-red-700 transition duration-300">
                  <TrashIcon class="w-5 h-5" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-if="showModal" class="fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50 p-4">
        <div class="bg-white w-full max-w-md rounded-lg shadow-xl p-6 space-y-4">
          <h3 class="text-xl font-bold text-gray-800">{{ modalMode === 'create' ? 'Create' : 'Edit' }} Working Time</h3>
          <form @submit.prevent="modalMode === 'create' ? createWorkingTime() : updateWorkingTime()">
            <div>
              <label for="start" class="text-sm font-medium text-gray-600">Start Time</label>
              <input v-model="formData.start" type="datetime-local" id="start" required class="w-full p-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
              <label for="end" class="text-sm font-medium text-gray-600">End Time</label>
              <input v-model="formData.end" type="datetime-local" id="end" required class="w-full p-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <div>
              <label for="user_id" class="text-sm font-medium text-gray-600">User ID</label>
              <input v-model="formData.user_id" type="number" id="user_id" required class="w-full p-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <div class="flex justify-end space-x-2 mt-4">
              <button type="button" @click="closeModal" class="bg-gray-400 text-white px-4 py-2 rounded hover:bg-gray-500">
                Cancel
              </button>
              <button type="submit" class="bg-gradient-to-r from-blue-500 to-indigo-600 text-white px-4 py-2 rounded hover:from-blue-600 hover:to-indigo-700">
                {{ modalMode === 'create' ? 'Create' : 'Update' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';
import { formatDate } from '../../utils/FormatDate';
import Toastify from 'toastify-js';
import "toastify-js/src/toastify.css";
import { PencilIcon, TrashIcon, PlusCircleIcon } from '@heroicons/vue/outline';


const API_URL = process.env.TIME_MANAGER_APP_URL || 'http://localhost:4000/api';
const route = useRoute();
const router = useRouter();

const workingTimes = ref([]);
const showModal = ref(false);
const modalMode = ref('create');
const formData = ref({ start: '', end: '', user_id: '' });

onMounted(async () => await fetchWorkingTimes());

const fetchWorkingTimes = async () => {
    try {
        const response = await axios.get(`${API_URL}/workingtime`);
        workingTimes.value = response.data.data || [];
    } catch (error) {
        console.error('Error fetching working times:', error);
        showToast('Error fetching working times', 'error');
    }
};

const openModal = (mode, workingTime = null) => {
    modalMode.value = mode;
    formData.value = mode === 'edit' && workingTime ? {
        ...workingTime,
        start: formatDate(workingTime.start),
        end: formatDate(workingTime.end)
    } : { start: '', end: '', user_id: '' };
    showModal.value = true;
};

const closeModal = () => showModal.value = false;

const createWorkingTime = async () => {
    try {
        const response = await axios.post(`${API_URL}/workingtime/${formData.value.user_id}`, { working_time: formData.value });
        await fetchWorkingTimes();
        closeModal();
        showToast('Working time created successfully!');
    } catch (error) {
        showToast('Error creating working time', 'error');
    }
};

const updateWorkingTime = async () => {
    try {
        await axios.put(`${API_URL}/workingtime/${formData.value.id}`, { working_time: formData.value });
        await fetchWorkingTimes();
        closeModal();
        showToast('Working time updated successfully!');
    } catch (error) {
        showToast('Error updating working time', 'error');
    }
};

const deleteWorkingTime = async (id) => {
    if (confirm('Are you sure you want to delete this working time?')) {
        try {
            await axios.delete(`${API_URL}/workingtime/${id}`);
            await fetchWorkingTimes();
            showToast('Working time deleted successfully!');
        } catch (error) {
            showToast('Error deleting working time', 'error');
        }
    }
};

//const formatDateForInput = (dateString) => new Date(dateString).toISOString().slice(0, 16);

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
</script>

<style>
@import 'toastify-js/src/toastify.css';
</style>
