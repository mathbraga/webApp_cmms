import React, { useState } from 'react'

export const UserContext = React.createContext();

export function UserProvider({ children }) {
  const [ user, setUser ] = useState(null);
  const [ team, setTeam ] = useState(null);
  const [ isLogged, setIsLogged ] = useState(false);
  
  return (
    <UserContext.Provider
      value={{
        user,
        team,
        isLogged,
        setUser,
        setTeam,
        setIsLogged
      }}
    >
      {children}
    </UserContext.Provider>
  )
}
