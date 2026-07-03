//
//  OnboardingPage.swift
//  Bowl
//
//  Content model for a single onboarding page. All three pages share the
//  same center illustration; only the headline and subtitle change.
//

import Foundation

struct OnboardingPage {
    let title: String
    let subtitle: String
}

extension OnboardingPage {

    /// The onboarding copy, in display order.
    static let all: [OnboardingPage] = [
        OnboardingPage(
            title: "내 고양이에게 맞는 사료",
            subtitle: "성분 기준으로 비교해보세요"
        ),
        OnboardingPage(
            title: "우리 아이 맞춤 영양 분석",
            subtitle: "생일과 묘종에 딱 맞는 적정 성분을 알려드려요"
        ),
        OnboardingPage(
            title: "칼슘과 인의 황금 비율",
            subtitle: "조회분과 미네랄 수치까지 꼼꼼하게 밸런스를 체크해요"
        )
    ]
}
