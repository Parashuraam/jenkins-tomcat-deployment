pipeline {
    
    agent {
        label "master"
    }
    
   parameters {
        choice(choices: ['Build', 'Deploy'], description: 'Select what do you want ?', name: 'Phase')
        choice(choices: ['Dev', 'Test', 'Stage', 'Prod'], description: 'Select env', name: 'Environment')
        choice(choices: ['master', 'feature', 'enhancement'], description: 'Select Branch env', name: 'Branch Name')
        string(defaultValue: "0.0.0.0-SNAPSHOT", description: 'Enter your Version number ', name: 'VERSION')
        string(defaultValue: "0.0.0.0", description: 'Enter your Docker image build number ', name: 'buildNumber')
        string(defaultValue: "maven-snapshots", description: 'Enter your Nexus artifact Repo Name ', name: 'REPOSITORY')
    }
    
    tools {
        // Note: this should match with the tool name configured in your jenkins instance (JENKINS_URL/configureTools/)
        maven "LocalMaven"
        //dockerTool "docker"
    }
    environment {
        // This can be nexus3 or nexus2
        NEXUS_VERSION = "nexus3"
        // This can be http or https
        NEXUS_PROTOCOL = "http"
        // Where your Nexus is running
        NEXUS_URL = "localhost:8081"
        // Repository where we will upload the artifact
        //NEXUS_REPOSITORY = "maven-snapshots"
        // Jenkins credential id to authenticate to Nexus OSS
        NEXUS_CREDENTIAL_ID = "nexus3"
    }
    stages {
        stage("Git Code Checkout") {
            steps {
                script {
                    // Let's clone the source
                    git 'https://github.com/Parashuraam/jenkins-tomcat-deployment.git';
                }
            }
        }
        stage("Maven Build") {
            steps {
                script {
                    // If you are using Windows then you should use "bat" step
                    // Since unit testing is out of the scope we skip them
                    bat "mvn clean package -DskipTests=true"
                }
            }
        }
		
		  stage("SonarQube Analysis") {
            steps {
                script {
 		       bat "mvn sonar:sonar -Dsonar.host.url=http://localhost:9000 -Dsonar.login=147d7279d333d11924eba2108b78e64bb210552d"
                    }
                }
            }
        
        
        
        stage("Publis to Nexus") {
            steps {
                script {
                    // Read POM xml file using 'readMavenPom' step , this step 'readMavenPom' is included in: https://plugins.jenkins.io/pipeline-utility-steps
                    pom = readMavenPom file: "pom.xml";
                    // Find built artifact under target folder
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    // Print some info from the artifact found
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    // Extract the path from the File found
                    artifactPath = filesByGlob[0].path;
                    // Assign to a boolean response verifying If the artifact name exists
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: "${params.VERSION}",
                            repository: "${params.REPOSITORY}",
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                // Artifact generated such as .jar, .ear and .war files.
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                // Lets upload the pom.xml file for additional information for Transitive dependencies
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]

                        );
                    } else {

                        error "*** File: ${artifactPath}, could not be found";

                    }

                }

            }

        }
        
        
        stage("Build Docker Image") {
            steps {
                script {
                    // If you are using Windows then you should use "bat" step
                    // Since unit testing is out of the scope we skip them
                     bat "docker build -t parashuraam/helloworld:${buildNumber} ."
                }
            }
        }
        
      
      
       stage("Push Docker Image") {
            steps {
                script {
                    // If you are using Windows then you should use "bat" step
                    // Since unit testing is out of the scope we skip them
                     withCredentials([string(credentialsId: 'DockerHubPwd', variable: 'DockerHubPwd')]) {
                     bat "docker login -u parashuraam -p ${DockerHubPwd}"
                    }
                  bat "docker push parashuraam/helloworld:${buildNumber}"
                }
            }
        }
        

        stage("Run Docker Image In Dev Server") {
            steps {
                script {
                    // If you are using Windows then you should use "bat" step
                    // Since unit testing is out of the scope we skip them
                     
		        bat "docker stop HelloWorld"
                        bat "docker rm HelloWorld"
                        bat "docker run  -d -p 8080:8080 --name HelloWorld parashuraam/helloworld:${buildNumber}"
                }
            }
        }


    }

}
