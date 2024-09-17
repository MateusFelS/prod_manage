require 'securerandom'
require 'date'

def generate_random_token(length = 6)
  SecureRandom.hex(length / 2)
end

current_date = Date.today.iso8601 

DATABASE = {
  user: {
    token: generate_random_token,
    password: '12332100',
    name: 'Matt'
  },

  employee: {
    name: 'Mateus',
    roleId: 1,
    entryDate: current_date
  },

  role: {
    title: 'Gerente',
    description: 'xxxx'
  },

  cut: {
    code: 'ABB',
    pieceAmount: 10,
    line1: 'B',
    line2: 'B',
    limiteDate: current_date,
    comment: 'teste',
    supplier: 'teste_2',
    employeeId: 1
  },

  performance: {
    employeeId: 1,
    date: current_date,
    schedules: {
      "07:00-08:00": 500,
      "08:00-09:00": 600,
      "09:10-10:10": 700
    },
    produced: 3000,
    meta: 3000,
  }
}
