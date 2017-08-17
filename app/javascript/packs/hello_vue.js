import Vue from 'vue'
import App from '../components/app.vue'

document.addEventListener('turbolinks:load', () => {
  var vm = new Vue(App).$mount('hello')
})
