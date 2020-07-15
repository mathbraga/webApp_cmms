import React from 'react';

export const userContext = React.createContext({
    user: null,
    cpf: "",
    email: "", 
    name: "", 
    personId: "", 
    role: "", 
    teams: []
});