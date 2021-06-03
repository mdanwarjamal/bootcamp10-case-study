try{
	node{
            def docker
            def dockerCMD
            def maven
            def mavenCMD
            def ansible
            def ansibleCMD
            def java
            def javaCMD
            def dockerImage
            def tagName
            def gitURL
            def projectName
            stage('prepare'){
                echo "Prepare Tools and Variables to be used in Pipeline Script"
                docker = tool name: 'sysDocker', type: 'dockerTool'
                dockerCMD = "${docker}/bin/docker"
                maven = tool name: 'myMaven', type: 'maven'
                mavenCMD = "${maven}/bin/mvn"
                ansible = tool name: 'sysAnsible', type: 'org.jenkinsci.plugins.ansible.AnsibleInstallation'
                ansibleCMD = "${ansible}/ansible"
                java = tool name: 'sysJDK', type: 'jdk'
                javaCMD = "${java}/bin/java"
                dockerImage = "mdanwarjamal/bootcamp10-case-study"
                tagName = "1.0"
                gitURL = "https://github.com/mdanwarjamal"
                gitSSH = "git@github.com:mdanwarjamal"
                projectName = "bootcamp10-case-study"
            }
            stage('checkout'){
                echo "Checkout Application Code from GitHub Repository"
                git branch: 'feature/htmlReport', credentialsId: 'GitHubSSH', url: "${gitSSH}/${projectName}.git"
            }
            stage('build'){
                echo "Build Application Code"
                sh "${mavenCMD} compile"
            }
            stage('package'){
                echo "Generate jar file for Application"
                sh "${mavenCMD} clean package"
            }
	    stage('surefire-test'){
		echo "Generate Surefire Test Reports"
	    	sh "${mavenCMD} test site"
	    }
            stage('publish surefire html report'){
                echo "Publish HTML Surefire Report for Junit"
                publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'target/site', reportFiles: 'surefire-report.html,dependencies.html,dependency-management.html,dependency-info.html', reportName: 'HTML Surefire Report', reportTitles: ''])
            }
	    stage('publish jacoco coverage test HTML reports'){
		echo "Publish Jacoco Coverage HTML Reports"
		publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'target/site/jacoco', reportFiles: 'index.html,jacoco-sessions.html', reportName: 'HTML Jacoco Report', reportTitles: ''])
	    }
            stage('build docker image'){
                echo "Build Docker image from Dockerfile"
                sh "${dockerCMD} build -t ${dockerImage}:${tagName} ."
            }
            stage('Push to DockerHub'){
                echo "Push Docker Image to DockerHub Online Registry"
                withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'dockerHubPwd', usernameVariable: 'dockerHubUsername')]) {
                    sh "${dockerCMD} login -u ${dockerHubUsername}  -p ${dockerHubPwd}"
                    sh "${dockerCMD} push  ${dockerImage}:${tagName}"
                }
            }
            stage('Deploy Application using Ansible'){
                echo "Installing Docker in Ansible host machines"
                echo "Deploying Spring Application using Ansible Playbooks"
                ansiblePlaybook credentialsId: 'Ansible', disableHostKeyChecking: true, installation: 'sysAnsible', inventory: '/etc/ansible/hosts', playbook: 'deployment.yml'
            }
            currentBuild.result = 'SUCCESS'
        }
}
catch(Exception ex){
        echo "Exception Occured"
        currentBuild.result = 'FAILURE'
}
finally{
        echo "FINALLY...BLOCK"
}
