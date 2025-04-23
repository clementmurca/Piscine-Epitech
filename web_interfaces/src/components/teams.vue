<template> 
  <div class="bg-white shadow-lg rounded-lg p-8">
    <h2 class="text-4xl font-bold mb-6 text-gray-800 bg-gradient-to-r from-blue-500 to-indigo-600 text-transparent bg-clip-text">
      Teams
    </h2>
    <!-- Create a team -->
    <div class="bg-white shadow-md rounded-lg p-6 my-8">
      <h2 class="text-2xl font-semibold mb-6 text-gray-800">Create a team</h2>
      <form @submit.prevent="createTeam" class="space-y-6">
        <div>
          <label for="team-name" class="block text-sm font-medium text-gray-700">Team Name</label>
          <input v-model="createNewTeam.name" type="text" id="team-name" placeholder="Enter team name" class="mt-2 w-full border border-gray-300 p-3 rounded-lg shadow-sm focus:outline-none focus:ring focus:ring-blue-200 focus:border-blue-500" />
        </div>
        <div>
          <label for="manager-select" class="block text-sm font-medium text-gray-700">Select Manager</label>
          <select v-model="createNewTeam.manager_id" id="manager-select" class="mt-2 w-full border text-gray-800 border-gray-300 p-3 rounded-lg shadow-sm focus:outline-none focus:ring focus:ring-blue-200 focus:border-blue-500">
            <option value="">Select a Manager</option>
            <option v-for="user in users.filter(user => user.role === 'manager')" :key="user.id" :value="user.id">{{ user.username }}</option>
          </select>
        </div>
        <button @click="openModal('create')" 
              class="flex items-center bg-gradient-to-r from-blue-500 to-indigo-600 text-white font-semibold px-6 py-3 rounded-lg mb-6 transition transform duration-200 hover:scale-105 shadow-lg">
        <PlusCircleIcon class="w-5 h-5 mr-2" />
        Create Team
      </button>
      </form>
    </div>

    <!-- Teams -->
    <div class="p-4">
      <h2 class="text-2xl text-gray-800 font-bold mb-4">All teams</h2>
      <table class="min-w-full bg-white border border-gray-200 rounded-lg" v-if="teams">
        <thead class="bg-blue-50">
          <tr class="text-gray-600 text-sm leading-normal" >
            <th class="py-3 px-6 text-left">Id</th>
            <th class="py-3 px-6 text-left">Name</th>
            <th class="py-3 px-6 text-left">Manager ID</th>
            <th class="py-3 px-6 text-center">Actions</th>
          </tr>
        </thead>
        <tbody class="text-gray-600 text-sm font-light">
          <tr v-for="(team, index) in teams" :key="index" class="border-b border-gray-200 hover:bg-gray-100">
            <td class="py-3 px-6 text-left">{{ team.id }}</td>
            <td class="py-3 px-6 text-left">{{ team.name }}</td>
            <td class="py-3 px-6 text-left">{{ team.manager_id }}</td>
            <td class="py-3 px-6 text-center">
              <button @click="deleteTeams(team.id)" class="text-red-500 hover:text-red-700 transition duration-300">
                <TrashIcon class="w-5 h-5" />
              </button>
            </td>
          </tr>
        </tbody>
      </table>
      <p v-else>No teams found</p>
    </div>

    <!-- Assign user to a team -->
    <div class="bg-white shadow-lg rounded-lg p-8">
      <div class="mb-4">
        <label for="team-select" class="block text-gray-700 font-semibold mb-2">Select Team:</label>
        <select id="team-select" v-model="selectedTeamId" class=" text-gray-800 block w-full px-4 py-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-200 focus:border-blue-500">
          <option value="">All Teams</option>
          <option v-for="team in teams" :key="team.id" :value="team.id">{{ team.name }}</option>
        </select>
      </div>

      <h2 class="text-3xl font-semibold mb-6 text-gray-800">Team Members : <span v-if="selectedTeam">{{ selectedTeam.name }}</span></h2>
      <div v-if="selectedTeam && selectedTeam.members.length" class="overflow-x-auto">
        <table class="min-w-full bg-white border border-gray-200 rounded-lg">
          <thead class="bg-blue-50">
            <tr class="text-gray-600 text-sm leading-normal">
              <th class="py-3 px-6 text-left">ID</th>
              <th class="py-3 px-6 text-left">Username</th>
              <th class="py-3 px-6 text-left">Email</th>
              <th class="py-3 px-6 text-center">Actions</th>
            </tr>
          </thead>
          <tbody class="text-gray-700 text-sm">
            <tr v-for="user in selectedTeam.members" :key="user.id" class="border-b border-gray-200 hover:bg-gray-50 transition duration-300">
              <td class="py-3 px-6">{{ user.id }}</td>
              <td class="py-3 px-6">{{ user.username }}</td>
              <td class="py-3 px-6">{{ user.email }}</td>
              <td class="py-3 px-6">
                <button @click="deleteUsersTeams(selectedTeam.id, user.id)" class="text-red-500 hover:text-red-700 transition duration-300">
                  <TrashIcon class="w-5 h-5" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p v-else class="text-gray-500 mt-4">No users found for this team</p>

      <h2 class="text-3xl font-semibold mb-6 text-gray-800 mt-8">Assign Users to Teams</h2>
      <div v-if="users.length" class="overflow-x-auto">
        <table class="min-w-full bg-white border border-gray-200 rounded-lg">
          <thead class="bg-blue-50">
            <tr class="text-gray-600 text-sm leading-normal">
              <th class="py-3 px-6 text-left">ID</th>
              <th class="py-3 px-6 text-left">Username</th>
              <th class="py-3 px-6 text-left">Email</th>
              <th class="py-3 px-6 text-left">Assign Team</th>
            </tr>
          </thead>
          <tbody class="text-gray-700 text-sm">
            <tr v-for="user in users" :key="user.id" class="border-b border-gray-200 hover:bg-gray-50 transition duration-300">
              <td class="py-3 px-6">{{ user.id }}</td>
              <td class="py-3 px-6">{{ user.username }}</td>
              <td class="py-3 px-6">{{ user.email }}</td>
              <td class="py-3 px-6">
                <select v-model="user.team_id" @change="assignTeam(user, user.team_id)" class="block w-full px-3 py-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-200 focus:border-blue-500">
                  <option value="">No Team</option>
                  <option v-for="team in teams" :key="team.id" :value="team.id">{{ team.name }}</option>
                </select>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p v-else class="text-gray-500 mt-4">No users available</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from "vue";
import axios from "axios";
import { showToast } from "../../utils/showToast";
import { TrashIcon, PlusCircleIcon } from "@heroicons/vue/outline";

const API_URL = process.env.TIME_MANAGER_APP_URL || "http://localhost:4000/api";

const selectedTeam = ref(null);
const users = ref([]);
const teams = ref([]);
const selectedTeamId = ref("");
const createNewTeam = ref({
  name: "",
  manager_id: "",
});

// Create team
const createTeam = async () => {
  if (!createNewTeam.value.name || !createNewTeam.value.manager_id) {
    showToast("Please provide both team name and manager.", "error");
    return;
  }

  try {
    const response = await axios.post(`${API_URL}/teams`, {
      team: createNewTeam.value,
    });
    showToast("Team created successfully", "success");
    fetchTeams();
  } catch (error) {
    console.error("Error creating team:", error.response?.data || error);
    showToast("Error creating team", "error");
  }
};

// delete a team
const deleteTeams = async (id) => {
  if (confirm('Are you sure you want to delete this user?')) {
    try {
      await axios.delete(`${API_URL}/teams/${id}`);
      await fetchUsers();
      showToast('User deleted successfully!', "success");
    } catch (error) {
      console.error('Error deleting user:', error);
      showToast('Error deleting user', 'error');
    }
  }
};

// delete a user to a team
const deleteUsersTeams = async (teamId, userId) => {
  if (confirm('Are you sure you want to delete this user?')) {
    try {
      await axios.delete(`${API_URL}/teams/${teamId}/remove_user/${userId}`);
      await fetchUsers();
      showToast('User deleted successfully!', "success");
    } catch (error) {
      console.error('Error deleting user:', error);
      showToast('Error deleting user', 'error');
    }
  }
};

// Fetch all users
const fetchUsers = async () => {
  try {
    const usersResponse = await axios.get(`${API_URL}/users`);
    users.value = usersResponse.data.data;
  } catch (error) {
    console.error("Error fetching users:", error);
    showToast("Error fetching users", "error");
  }
};

// Filtrer users
const filteredUsers = computed(() => {
  if (!selectedTeamId.value) {
    return users.value;
  }
  return users.value.filter((user) => user.team_id === selectedTeamId.value);
});

// Fetch all teams
const fetchTeams = async () => {
  try {
    const teamsResponse = await axios.get(`${API_URL}/teams`);
    teams.value = teamsResponse.data.data;
  } catch (error) {
    console.error("Error fetching teams:", error);
    showToast("Error fetching teams", "error");
  }
};

// Fetch team by id
const fetchTeamById = async (teamId) => {
  try {
    const response = await axios.get(`${API_URL}/teams/${teamId}`);
    selectedTeam.value = response.data.data;
  } catch (error) {
    console.error(`Error fetching team with ID ${teamId}:`, error);
    showToast(`Error fetching team with ID ${teamId}`, "error");
  }
};

// Watch for team selection and update accordingly
watch(selectedTeamId, async (newTeamId) => {
  if (newTeamId) {
    await fetchTeamById(newTeamId);
  } else {
    selectedTeam.value = null;
  }
});

// Assigner a team to a user
const assignTeam = async (user, teamId) => {
  try {
    await axios.post(`${API_URL}/teams/${teamId}/add_user/${user.id}`);
    showToast("Team assigned successfully", "success");
  } catch (error) {
    console.error("Error assigning team:", error.response?.data || error);
    showToast("Error assigning team", "error");
  }
};

// Fetch all users and teams
onMounted(() => {
  fetchTeams();
  fetchUsers();
});
</script>