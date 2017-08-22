<template>
  <button v-if="formHidden" v-on:click="formHidden = false">New Company</button>
  <div v-else>
    <form action="/companies" method="post">
      <div class="company-form">
        <span v-on:click="formHidden = true">x</span>
        <input v-model="company.name" type="text" placeholder="Name">
        <input v-model="company.code" type="text" placeholder="Shortcode">
        <input v-model="company.str_addr" type="text" placeholder="Address">
        <input v-model="company.city" type="text" placeholder="City">
        <button id="company-form-submit" v-on:click.prevent v-on:click="createCompany">Create</button>
      </div>
    </form>
  </div>
</template>

<script>
export default {
  data: function() {
    return {
      formHidden: true,
      company: {
        name: '',
        code: '',
        str_addr: '',
        city: ''
      }
    }
  },

  methods: {
    resetForm () { Object.assign(this.$data, this.$options.data()); },
    createCompany: function() {
      document.getElementById('company-form-submit').disabled = "true";

      this.$http.post('/user/companies', { company: this.company })
      .then(response => {
        let flashObj = {}
        flashObj[this.company.name] = ["was successfully created."] 
        flashMessages({ success: flashObj });
        this.resetForm();
        this.$emit('companyCreated', response.body);
      }, response => {
        flashMessages({ error: response.body });
        document.getElementById('company-form-submit').removeAttribute('disabled');
      });
    }
  }
}

function flashMessages(msg) {
  let flashList = document.getElementById('flash');
  emptyElement(flashList);

  let msgType   = Object.keys(msg)[0];

  for (var attr in msg[msgType]) {
    for (var index in msg[msgType][attr]) {
      let msgText   = `${attr} ${msg[msgType][attr][index]}`;
      let flashItem = document.createElement('li');

      flashItem.setAttribute('class', msgType);
      flashItem.appendChild(document.createTextNode(msgText));
      flashList.appendChild(flashItem);
    }
  }
}

function emptyElement(el) {
  while (el.firstChild) { el.removeChild(el.firstChild); }
}
</script>

<style scoped>
.company-form input {
    display: inline-block;
}
</style>
