import React, { useState } from 'react'

export const UserContext = React.createContext();

export function UserProvider({ children }) {
  const [ user, setUser ] = useState(null);
  const [ team, setTeam ] = useState(null);
  const [ isLogged, setIsLogged ] = useState(false);
  
  function login(user, team) {
    if (user && team) {
      setUser(user);
      setTeam(team);
      setIsLogged(true);
    }
  }
  
  function logout() {
    setUser(null);
    setTeam(null);
    setIsLogged(false);
  }
  
  return (
    <UserContext.Provider
      value={{
        user,
        team,
        isLogged,
        login,
        logout
      }}
    >
      {children}
    </UserContext.Provider>
  )
}
