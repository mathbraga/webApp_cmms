import React from 'react';

export const userContext = React.createContext({
    user: {
        id: null,
        name: null,
        email: null
    }
});