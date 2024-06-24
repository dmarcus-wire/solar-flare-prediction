ocp_aws_get_key(){
  # get aws creds
  ocp_aws_cluster || return 1
  
  AWS_ACCESS_KEY_ID=$(oc -n kube-system extract secret/aws-creds --keys=aws_access_key_id --to=-)
  AWS_SECRET_ACCESS_KEY=$(oc -n kube-system extract secret/aws-creds --keys=aws_secret_access_key --to=-)
  AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-2}

  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_DEFAULT_REGION

  echo "AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION}"
}