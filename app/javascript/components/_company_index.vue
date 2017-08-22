<template>
  <div class="company_index">
    <h2>Companies</h2>
    <add-company-form @companyCreated="reloadIndex"></add-company-form>
    <div v-for="company in companies" class="company_snippet">
      <h3 class="company_name">{{ company.name }} ({{ company.code }})</h3>
      <p class="company_city">{{ company.city }}</p>
    </div>
  </div>
</template>

<script>
import AddCompanyForm from './_add_company_form.vue'

export default {
  data: function() {
    return {
      companies: JSON.parse(document.getElementById('companies_list').getAttribute('value'))
    }
  },

  methods: {
    reloadIndex(companyList) {
      this.companies = companyList;
    }
  },

  components: {
    AddCompanyForm
  }
}
</script>

<style scoped>
</style>
