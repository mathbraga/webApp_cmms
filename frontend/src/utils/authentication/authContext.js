import React from 'react';

export default React.createContext({
    user: null,
    login: (user) => {},
    logout: () => {}
})