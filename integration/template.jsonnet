// SAM template
{
  AWSTemplateFormatVersion: '2010-09-09',
  Transform: 'AWS::Serverless-2016-10-31',
  Description: '',

  Resources: {
    AppFunction: {
      Type: 'AWS::Serverless::Function',  // https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction
      Properties: {
        PackageType: 'Image',
        FunctionUrlConfig: { AuthType: 'NONE' },
      },
      Metadata: {
        DockerContext: '..',
        Dockerfile: 'Dockerfile.integration',
      },
    },
  },
  Outputs: {
    AppUrl: {
      Description: 'app endpoint',
      Value: { 'Fn::GetAtt': ['AppFunctionUrl', 'FunctionUrl'] },
    },
  },
}
