<template>
    <div class="bg-white shadow-lg rounded-lg p-8" >
        <h2 class="text-4xl font-bold mb-6 text-gray-800 bg-gradient-to-r from-blue-500 to-indigo-600 text-transparent bg-clip-text">
     Team Members
    </h2>
        <div v-if="teams.length" class="overflow-x-auto">
            <div v-for="team in teams" :key="team.id" class="mb-6">
                <h2 class="text-2xl font-semibold mb-4 text-gray-800">{{ team.name }}</h2>
                <table class="min-w-full bg-white border border-gray-200 rounded-lg">
                    <thead class="bg-blue-50">
                        <tr class="text-gray-600 text-sm leading-normal">
                            <th class="py-3 px-6 text-left">ID</th>
                            <th class="py-3 px-6 text-left">Username</th>
                            <th class="py-3 px-6 text-left">Email</th>
                        </tr>
                        </thead>
                        <tbody class="text-gray-700 text-sm">
                            <!-- Boucle sur les membres de chaque équipe -->
                        <tr v-for="user in team.members" :key="user.id" class="border-b border-gray-200 hover:bg-gray-50 transition duration-300">
                            <td class="py-3 px-6">{{ user.id }}</td>
                            <td class="py-3 px-6">{{ user.username }}</td>
                            <td class="py-3 px-6">{{ user.email }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <p v-else class="text-gray-500 mt-4">No teams found for this user.</p>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";


const API_URL = "http://localhost:4000/api";
const teams = ref([]);
const users = ref([]);

const fetchTeamsForUser = async () => {
    try {
        const token = localStorage.getItem("jwt");
        const response = await axios.get(`${API_URL}/teams/`);
        teams.value = response.data.data;
    } catch (error) {
        console.error(`Error fetching teams for user with ID ${userId}:`, error);
        alert("Error fetching teams. Please try again.");
    }
};

onMounted(() => {
    fetchTeamsForUser();
})

</script>
