// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is auto generated.
// To update all the settings.gradle files in the Flutter repo,
// See dev/tools/bin/generate_gradle_lockfiles.dart.

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.value(
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
)

subprojects {
    project.layout.buildDirectory.value(
        rootProject.layout.buildDirectory
            .dir(project.name)
            .get()
    )
}
// Stripe Issuing push provisioning references Google's private TapAndPay SDK.
// KabulFit uses PaymentSheet, not card-issuer push provisioning. Keep the Stripe
// library itself (needed by the plugin's Kotlin code), and exclude only the
// non-public Google dependency from resolution.
subprojects {
    if (name == "app" || name == "stripe_android") {
        configurations.configureEach {
            exclude(group = "com.google.android.gms", module = "play-services-tapandpay")
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
