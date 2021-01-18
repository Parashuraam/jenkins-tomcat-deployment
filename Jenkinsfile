pipeline {
    
    agent {
        label "master"
    }
    
   parameters {
        choice(choices: ['Build', 'Deploy'], description: 'Select what do you want ?', name: 'Phase')
        choice(choices: ['Dev', 'Test', 'Stage', 'Prod'], description: 'Select env', name: 'Environment')
        choice(choices: ['master', 'feature', 'enhancement'], description: 'Select Branch env', name: 'Branch Name')
        string(defaultValue: "0.0.0.0-SNAPSHOT", description: 'Enter your Version number ', name: 'VERSION')
string(defaultValue: "maven-snapshots", description: 'Enter your Nexus artifact Repo Name ', name: 'REPOSITORY')
    }
    
    tools {
        // Note: this should match with the tool name configured in your jenkins instance (JENKINS_URL/configureTools/)
        maven "LocalMaven"
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
        stage("clone code") {
            steps {
                script {
                    // Let's clone the source
                    git 'https://github.com/Parashuraam/jenkins-tomcat-deployment.git';
                }
            }
        }
        stage("mvn build") {
            steps {
                script {
                    // If you are using Windows then you should use "bat" step
                    // Since unit testing is out of the scope we skip them
                    bat "mvn clean package -DskipTests=true"
                }
            }
        }
        stage("publish to nexus") {
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
        
        
        stage("Deply to Tomcat") {
            steps {
                script {
                    // Let's deploy artifact to tomcat
                    deploy adapters: [tomcat9(url: 'http://localhost:8080/', credentialsId: 'tomcat9')], war: 'target/*.war', contextPath: 'HelloWorld'
                }
            }
        }


    }

}