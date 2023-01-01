#!/usr/bin/env groovy

library identifier: 'jenkins-shared-lib@master', retriever: modernSCM(
        [$class: 'GitSCMSource',
         remote: 'https://github.com/Gufran07/guffi7.git',
         credentialsId: '7375654c-8817-4760-9e6c-ef8e9768570e'
        ]
)


def gv

pipeline {
    agent any
    tools {
        maven "Maven-3.8.6"
    }
    stages {
        stage("init") {
            steps {
                script {
                    gv = load "jenkins-shared-lib/script.groovy"
                }
            }
        }
        stage("build jar") {
            steps {
                script {
                    buildJar()
                }
            }
        }
        stage("build and push image") {
            steps {
                script {
                    buildImage 'guffi/guffi-docker:jma-3.0'
                    dockerLogin()
                    dockerPush 'guffi/guffi-docker:jma-3.0'
                }
            }
        }
        stage("deploy") {
            steps {
                script {
                    gv.deployApp()
                }
            }
        }
    }
}
