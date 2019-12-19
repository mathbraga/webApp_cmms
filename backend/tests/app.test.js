const request = require('supertest');
const app = require('../app');

describe('Test all app middlewares', () => {
  
  test('Authentication', async () => {
    try {
      const response = await request(app)
      .post('/auth/login')
      .send({
        email: 'hzlopes@senado.leg.br',
        password: '123456',
      });
      expect(response.statusCode).toBe(200);
    } catch (err) {
      console.log(err);
    }
  });
  
  test('Postgraphile', async () => {
    try {
      const response = await request(app)
      .post('/db')
      .send({
        query: 'query IntrospectionQuery { __schema { queryType { name } mutationType { name } subscriptionType { name } types { ...FullType } directives { name description locations args { ...InputValue } } } } fragment FullType on __Type { kind name description fields(includeDeprecated: true) { name description args { ...InputValue } type { ...TypeRef } isDeprecated deprecationReason } inputFields { ...InputValue } interfaces { ...TypeRef } enumValues(includeDeprecated: true) { name description isDeprecated deprecationReason } possibleTypes { ...TypeRef } } fragment InputValue on __InputValue { name description type { ...TypeRef } defaultValue } fragment TypeRef on __Type { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name } } } } } } } }'
      });
      expect(response.statusCode).toBe(200);
    } catch (err) {
      console.log(err);
    }
  });

});
