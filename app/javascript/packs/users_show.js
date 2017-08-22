import Vue from 'vue'
import VueResource from 'vue-resource'
import CompanyIndex from '../components/_company_index.vue'

Vue.use(VueResource)

document.addEventListener('turbolinks:load', () => {
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  var vm = new Vue(CompanyIndex).$mount('company-index')
})
