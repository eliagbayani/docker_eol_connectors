import jenkins.model.*
Jenkins.instance.setNumExecutors(15) // Recommended to not run builds on the built-in node