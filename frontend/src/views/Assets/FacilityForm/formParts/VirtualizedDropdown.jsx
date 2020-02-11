import React, { Component } from 'react';

export default function VirtualizedDropdown(WrappedComponent){
    class VirtualizedDropdown extends Component{
        constructor(props){
            super(props);
        }

        render(){
            console.log(this.props.formData.parentOptions.length);
            return(
                <WrappedComponent
                    {...this.props}
                />
            );
        }
    }

return VirtualizedDropdown;
}