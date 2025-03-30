import { test, expect } from '@playwright/test';

const BASE_URL = process.env.BASE_URL;
const MANAGEMENT_TOKEN = process.env.MANAGEMENT_TOKEN;
const INVALID_TOKEN = process.env.INVALID_TOKEN;

let entryId: string;

test.describe('API - Empregado', () => {
    test('Deve obter a lista de empregados', async({ request }) => {
        const get_response = await request.get(`${BASE_URL}?content_type=employe`, {
            headers: { Authorization: `Bearer ${MANAGEMENT_TOKEN}` }
        });
        expect(get_response.status()).toBe(200);
        const data = await get_response.json();
        expect(data.items).toBeInstanceOf(Array);
        expect(data.items.length).toBeGreaterThan(0);
    
        const employee = data.items[0].fields;
        expect(employee).toHaveProperty('name');
        expect(employee).toHaveProperty('role');
    })

    test('Deve criar um novo empregado e depois deletar', async ({ request }) => {
        //Criar empregado
        const post_response = await request.post(BASE_URL, {
          headers: {
            Authorization: `Bearer ${MANAGEMENT_TOKEN}`,
            'Content-Type': 'application/vnd.contentful.management.v1+json',
            'X-Contentful-Content-Type': 'employe'
          },
          data: {
            fields: {
              name: { 'en-US': 'Empregado Temporário' },
              role: { 'en-US': 'Costureiro' }
            }
          }
        });
    
        const data = await post_response.json();
        console.log('🔍 Resposta da API (Criação):', data);
    
        expect(post_response.status()).toBe(201);
        expect(data.sys).toHaveProperty('id');
    
        entryId = data.sys.id;
    
        //Deletar empregado
        const delete_response = await request.delete(`${BASE_URL}/${entryId}`, {
          headers: { Authorization: `Bearer ${MANAGEMENT_TOKEN}` }
        });
    
        expect(delete_response.status()).toBe(204);
      });

})

test.describe('API - Testes Negativos - Empregado', () => {
  
  test('Não deve obter a lista de empregados sem token de autenticação', async ({ request }) => {
    const get_response = await request.get(`${BASE_URL}?content_type=employe`, { failOnStatusCode: false });

    expect(get_response.status()).toBe(401);
  });

  test('Não deve obter a lista de empregados com token inválido', async ({ request }) => {
    const get_response = await request.get(`${BASE_URL}?content_type=employe`, {
      headers: { Authorization: `Bearer ${INVALID_TOKEN}` },
      failOnStatusCode: false
    });

    expect(get_response.status()).toBe(401);
  });

  test('Não deve deletar um empregado inexistente', async ({ request }) => {
    const fakeEntryId = 'invalidEntry123';

    const delete_response = await request.delete(`${BASE_URL}/${fakeEntryId}`, {
      headers: { Authorization: `Bearer ${MANAGEMENT_TOKEN}` },
      failOnStatusCode: false
    });
  
    expect(delete_response.status()).toBe(404);
  });
});
