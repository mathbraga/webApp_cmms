const request = require('supertest');
const app = require('../app');
const { pgPool } = require('../db');

describe('Test all middlewares and routes', () => {
  
  afterAll(async () => {
    await pgPool.end();
  });

  test('Passport (authentication)', async () => {
    const response = await request(app)
    .post('/auth/login')
    .send({
      email: 'hzlopes@senado.leg.br',
      password: '123456',
    })
    .expect('Set-Cookie', /cmms:user/)
    .expect(200);
  });

  // test('GraphQL-Upload (uploads)', async () => {
  //   const response = await request(app)
  //   .post('/db')
  //   .field({
  //     query: 'mutation MyMutation { __typename }',
  //     variables: {
  //       filesMetadata: {
  //         uuid: 'uuid',
  //         filename: 'filename',
  //         size: 123456,
  //       }
  //     }
  //   })
  //   .attach('variables[files]', '../public/images/newfile-1.jpeg')
  //   .set('Content-Type', 'multipart/form-data')
  //   .send({
  //     query: 'mutation MyMutation { __typename }',
  //     variables: {
  //       files: 'Buffer.alloc(10)',
  //       filesMetadata: {
  //         uuid: 'uuid',
  //         filename: 'filename',
  //         size: 123456,
  //       }
  //     }
  //   })
  //   .expect(200);
  // });
  
  test('Postgraphile (introspection query)', async () => {
    const response = await request(app)
    .post('/db')
    .send({
      query: 'query IntrospectionQuery { __schema { queryType { name } mutationType { name } subscriptionType { name } types { ...FullType } directives { name description locations args { ...InputValue } } } } fragment FullType on __Type { kind name description fields(includeDeprecated: true) { name description args { ...InputValue } type { ...TypeRef } isDeprecated deprecationReason } inputFields { ...InputValue } interfaces { ...TypeRef } enumValues(includeDeprecated: true) { name description isDeprecated deprecationReason } possibleTypes { ...TypeRef } } fragment InputValue on __InputValue { name description type { ...TypeRef } defaultValue } fragment TypeRef on __Type { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name ofType { kind name } } } } } } } }'
    })
    .expect(200);
  });

});
