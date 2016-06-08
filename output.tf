output "jenkins_public_dns" {
  value = "[ ${aws_instance.jenkins.public_dns} ]"
}
