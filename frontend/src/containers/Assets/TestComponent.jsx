import React from 'react';
import gql from 'graphql-tag';
import { Query } from 'react-apollo';

const category = 'E';

const testQuery = gql`
    query ($category: AssetCategoryType!) {
        allAssets(condition: {category: $category}) {
            edges {
                node {
                    parent
                    name
                    model
                    manufacturer
                    assetId
                    category
                    serialnum
                    area
                }
            }
        }
    }`;

const TestComponent = () => (
    <Query 
        query={testQuery}
        variables={{ category }}
        notifyOnNetworkStatusChange={true}
    >
        {({ data }) => {
            console.log(data);

            return <div>{data}</div>
        }}
    </Query>
);

export default TestComponent;