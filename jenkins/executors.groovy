import jenkins.model.*
Jenkins.instance.setNumExecutors(7) // Recommended to not run builds on the built-in node