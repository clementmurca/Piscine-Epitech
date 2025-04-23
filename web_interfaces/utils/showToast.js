import Toastify from 'toastify-js';
import "toastify-js/src/toastify.css";

export const showToast = (message, type) => {
  Toastify({
      text: message,
      duration: 3000,
      gravity: "top", 
      position: "right", 
      backgroundColor: type === 'success' ? "green" : "red",
      stopOnFocus: true, 
  }).showToast();
};