require 'securerandom'
require 'date'

def generate_random_token(length = 6)
  SecureRandom.hex(length / 2)
end

# Variáveis
id = 1
roleId = 1
pieceAmount = 10
selectedOperations = 1
employeeId = 1
calculatedTime = '00:00:15'

current_date = Date.today.iso8601 

DATABASE = {
  user: {
    id: id,
    token: generate_random_token,
    password: '',
    name: ''
  },

  employee: {
    id: id,
    name: '',
    roleId: roleId,
    entryDate: current_date
  },

  role: {
    id: id,
    title: '', # Cada role tem um 'title' único no Banco de Dados
    description: ''
  },

  cut: {
    id: id,
    code: '',
    pieceAmount: pieceAmount,
    line1: '',
    line2: '',
    limiteDate: current_date,
    comment: '',
    supplier: '',
    selectedOperations: selectedOperations
  },

  operation: {
    id: id,
    operationName: '', # Cada operation tem um 'operationName' único no Banco de Dados
    calculatedTime: calculatedTime
  },
  
  operation_set: {
    id: id,
    setName: '', # Cada operations_set tem um 'setName' único no Banco de Dados
    operationRecords: {
      "operationName": '',
      "calculatedTime": calculatedTime,
    }
  },

  performance: {
    id: id,
    employeeId: employeeId,
    date: current_date,
    schedules: {
      "piecesMade": 6300,
      "target100": 9000,
      "target70": 6300,
      "efficiency": "Aceitável"
    },
    produced: 3000,
    meta: 3000,
  }
}
