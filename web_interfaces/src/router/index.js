// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router';
import WorkingTime from '../components/WorkingTime.vue';
import User from '@/components/User.vue';
import ClockManager from '@/components/ClockManager.vue';
import WorkingTimes from '@/components/WorkingTimes.vue';
import ChartManager from '@/components/ChartManager.vue';
import Register from '@/components/Register.vue';
import Login from '@/components/Login.vue';
import Profile from '@/components/Profile.vue';
import Teams from '@/components/Teams.vue';
import TeamsEmployee from '@/components/TeamsEmployee.vue';

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', component: Login },
  { path: '/register', component: Register },
  {
    path: '/users',
    component: User,
    meta: { requiresAuth: true, roles: ['Admin', 'general_manager']  },
  },
  {
    path: '/working-time/:userid',
    component: WorkingTime,
    meta: { requiresAuth: true, roles: ['Admin', 'general_manager', 'manager', 'employee'] },
  },
  {
    path: '/working-times/:userid',
    component: WorkingTimes,
    meta: { requiresAuth: true,roles: ['Admin', 'general_manager', 'manager', 'employee'] },
  },
  {
    path: '/clock/:userid',
    component: ClockManager,
    meta: { requiresAuth: true, roles: ['Admin', 'general_manager', 'manager', 'employee'] },
  },
  {
    path: '/chartManager/:userid',
    component: ChartManager,
    meta: { requiresAuth: true, roles: ['Admin', 'general_manager', 'manager', 'employee'] },
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('@/components/Profile.vue'),  
    meta: { requiresAuth: true,  roles: ['Admin', 'general_manager', 'manager', 'employee'] }
  },
  {
    path: '/teams',
    component: 'Teams',
    component: () => import('@/components/Teams.vue'), 
    meta: { requiresAuth: true, roles: ['Admin', 'general_manager', 'manager', 'employee']  },
  },
  {
    path: '/teamsEmployee',
    component: 'TeamsEmployee',
    component: () => import('@/components/TeamsEmployee.vue'), 
    meta: { requiresAuth: true, roles: ['Admin', 'general_manager', 'manager', 'employee']  },
  },
  {
    path: '/userDashboard',
    component: 'UserDashboard',
    component: () => import('@/components/UserDashboard.vue'), 
    meta: { requiresAuth: true, roles: ['Admin', 'general_manager', 'manager', 'employee']  },
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Global navigation guard to check if the user is authenticated
router.beforeEach((to, from, next) => {
  const user = JSON.parse(localStorage.getItem('user'));
  const isAuthenticated = !!user;  

  if (to.meta.requiresAuth && !isAuthenticated) {
    
    next('/login');
  } else {
    next(); 
  }
});

export default router;